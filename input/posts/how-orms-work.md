Title: How do Object Relational Mappers (like Entity Framework) work?
Published: 12/21/2019
Tags:

 - csharp
 - orm
 - ef
---

When connecting an app or website to a database, most of the time you're querying the database and mapping the result to strongly typed objects. If you've been using an ORM like Enitity Framework or a Micro-ORM like Dapper, they handle the mapping of the objects and translation of the queries between C# and SQL.

**This article is a part of the [3rd annual C# advent calendar](https://crosscuttingconcerns.com/The-Third-Annual-csharp-Advent).**

The idea of ORMs is simple, since most of the code mapping code is mechanical and repetitive, it's a very good candidate for automation. Lets assume we have a `Person` table with this schema:

| Column    	| DataType     	|
|-----------	|--------------	|
| Id        	| int          	|
| Name      	| nvarchar(50) 	|
| Height       	| float        	|
| Birthdate 	| datetime     	| 

And we have a corresponding `Person` class:

```csharp
class Person
{
   public int Id { get; set; }
   public string Name { get; set; }
   public double Height { get; set; }
   public DateTime Birthdate { get; set; }
}
```

Here is the C# code if we manually retrieve the data and map it to a list of the `Person` class:

```csharp
public async Task<List<Person>> GetPeople()
{
    var list = new List<Person>();

    var sql = "SELECT Id, Name, Height, Birthdate From Person";

    using (var connection = new SqlConnection(ConnectionString))
    using (var command = new SqlCommand(sql, connection))
    {
        await connection.OpenAsync();

        using (var reader = await command.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                var person = new Person
                {
                    Id = (int)reader["Id"],
                    Name = (string)reader["Name"],
                    Height = (double)reader["Height"],
                    Birthdate = (DateTime)reader["Birthdate"],
                };

                list.Add(person);
            }
        }
    }

    return list;
}
```

The SQL query and the mapping of columns to properties are the only two things that differ from one table/class to another. If only we can get the list of properties of a class and their types... Well, it turns out that we can!

System.Reflection.Type represents a .NET type. It has a lot of metadata about the type. We can get the list of the properties of a type by using the `GetProperties` method:

```csharp
PropertyInfo[] properties = typeof(Person).GetProperties();
```

The `typeof` keyword is used to get the type of a class at compile time. The `PropertyInfo` class has many useful properties and methods, but we are only interested in these:

| Member    	| Type       	| Description                             	|
|-----------	|------------	|-----------------------------------------	|
| Name      	| string     	| Gets the name for a property.           	|
| GetMethod 	| MethodInfo 	| Gets the `get` method of a property. 	|
| SetMethod 	| MethodInfo 	| Gets the `set` method of a property. 	|

For example, if we have this code:
```csharp
var person = new Person
{
    Name = "Ahmed",
    Height = 180.4,
    Birthdate = new DateTime(1998, 1, 1),
    Id = 24
};

var heightProperty = typeof(Person).GetProperty(nameof(Person.Height));
heightProperty.SetValue(person, 185);

var properies = typeof(Person).GetProperties();
foreach (var prop in properies)
{
    Console.WriteLine($"{prop.Name} => {prop.GetValue(person)}");
}
```

This will be the output:
```
Height => 185
Id => 24
Name => Ahmed
Birthdate => 1/1/1998 12:00:00 AM
```
**Note**: It's interesting to see that because we fetched the metadata of `Height` above the loop using `GetProperty`, the order of returned properties from `GetProperties` has changed and `Height` is the first property.

As you can see, the value of height is changed from `180.4` to `185` by using reflection.

The second thing we needed was to generate an SQL query, which is very easy as well:

```csharp
var columnNames = properties.Select(p => p.Name);
var columns = string.Join(", ", columnNames);

var sql = $"SELECT {columns} FROM {typeof(T).Name}";
Console.WriteLine(sql);
```
**Note**: If you are not sure why `GetSelectQuery` has a `<T>` at the end, it's because the method is generic. It allows `GetSelectQuery<T>` to be called with any type the programmer likes. In the example above, we have used it with `Person`. Generics is a very powerful concept. You can learn more about generics from [Jeremy Clark](https://www.youtube.com/watch?v=J9Cwi45UtZU&list=PLdbkZkVDyKZURWIWQOw2KubVRIsxdkflI).

This will be the output:
```
SELECT Id, Name, Height, Birthdate FROM Person
```

If you take close look at the generated SQL query, it's exactly like our own hand written query. So now we can combine our new found knowledge to write a method that can query the database for any table we like and map the results to c# types:

```csharp
public async Task<List<T>> GetAll<T>() where T : new()
{
    var list = new List<T>();

    var properties = typeof(T).GetProperties();

    var columnNames = properties.Select(p => p.Name);
    var columns = string.Join(", ", columnNames);

    var sql = $"SELECT {columns} FROM {typeof(T).Name}";

    using (var connection = new SqlConnection(ConnectionString))
    using (var command = new SqlCommand(sql, connection))
    {
        await connection.OpenAsync();

        using (var reader = await command.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                var model = new T();

                foreach (var property in properties)
                {
                    property.SetValue(model, reader[property.Name]);
                }

                list.Add(model);
            }
        }
    }

    return list;
}
```
**Note**: the `new()` constraint makes sure the `T` has a public constructor that takes no parameters. So that we can write `var model = new T();`.

And we can use it like so:

```
List<Person> people = GetAll<Person>();
```
Pretty neat right?

And here is what `Insert` and `Update` would look like:

```csharp
public async Task Insert<T>(T item)
{
    var properties = typeof(T).GetProperties();

    var columns = string.Join(", ", properties.Select(p => p.Name));
    var columnParameters = string.Join(", ", properties.Select(p => $"@{p.Name}"));

    var sql = $"INSERT INTO {typeof(T).Name} ({columns}) VALUES ({columnParameters})";

    using (var connection = new SqlConnection(ConnectionString))
    using (var command = new SqlCommand(sql, connection))
    {
        await connection.OpenAsync();

        foreach (var property in properties)
        {
            command.Parameters.AddWithValue($"@{property.Name}", property.GetValue(item));
        }

        await command.ExecuteNonQueryAsync();
    }
}

public async Task Update<T>(string idPropertyName, T item)
{
    var properties = typeof(T).GetProperties();

    var columnUpdates = properties.Where(p => p.Name != idPropertyName)
                                  .Select(p => $"{p.Name} = @{p.Name}");
    var columns = string.Join(", ", columnUpdates);

    var sql = $"UPDATE {typeof(T).Name} SET {columns} WHERE {idPropertyName} = @{idPropertyName}";

    using (var connection = new SqlConnection(ConnectionString))
    using (var command = new SqlCommand(sql, connection))
    {
        await connection.OpenAsync();

        foreach (var property in properties)
        {
            command.Parameters.AddWithValue($"@{property.Name}", property.GetValue(item));
        }

        await command.ExecuteNonQueryAsync();
    }
}
```

As you can see, with a few lines of code we were able to implement a bare minimum Micro-ORM. But there are a lot of features in an ORM. One of them is that ORMs usually support multiple DBMSs, we only support MSSQL with our implementation here (Although for a simple mapper like this one, it's not very hard to support other DBMSs). Another thing would be providing a way to query the database (adding where clauses in the `GetAll` method). It's usually implemented using [`ExpressionTree`s](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/expression-trees/).

And the way we have implemented, it won't have a very good performance. Some easy tricks to improve performance would be cache the `PropertyInfo`s for each type and reuse it, because reflection is very expensive. Actual ORMs much better optimized both in the c# side and in the way they generate SQL.

The code for this article is available [on GitHub](https://github.com/encrypt0r/ORMSample).

**Disclaimer**: The sample codes in this article are for demonstration purposes alone and should NOT be used in production environments.