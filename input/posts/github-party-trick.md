Title: GitHub Party Trick
Published: 08/25/2020
Tags:

 - github
---

GitHub associates commits with people via email addresses. Each commit is signed with a commit and a name. So when you push a repo to GitHub, it looks for a user with that email address and associates the commit with that user. This allows some cool tricks!

You can commit as your favorite programmer in your repositories! [Example](https://github.com/encrypt0r/trick/graphs/contributors):

![List of contributors contains Rhyan Dhall, Rich Harris, and Linus Torvalds](..\assets\images\posts\github-party-trick\contributors.png)

In a repository, change your email address to their email address:

```
git config user.email "email@example.com"
```

Optional: Change your name to their name too!

```
git config user.name "Famous Person"
```

And now you can commit and push to GitHub. Now GitHub associates the commits with their account!

Note: The commits don't show up on their profile page. GitHub [has this to say](https://docs.github.com/en/github/setting-up-and-managing-your-github-profile/why-are-my-contributions-not-showing-up-on-my-profile#commits) about showing commits on a user's profile:

> Commits will appear on your contributions graph if they meet **all** of the following conditions:
>
> - The email address used for the commits is associated with your GitHub account.
> - The commits were made in a standalone repository, not a fork.
> - The commits were made:
>   - In the repository's default branch (usually `master`)
>   - In the `gh-pages` branch (for repositories with project sites)
>
> For more information on project sites, see "[About GitHub Pages](https://docs.github.com/en/github/working-with-github-pages/about-github-pages#types-of-github-pages-sites)."
>
> In addition, **at least one** of the following must be true:
>
> - You are a collaborator on the repository or are a member of the organization that owns the repository.
> - You have forked the repository.
> - You have opened a pull request or issue in the repository.
> - You have starred the repository.

**DISCLAIMER:** 

![Identity theft is not a joke~](https://s.yimg.com/ny/api/res/1.2/27_UvTRiSb4a5C42zgkIeQ--~A/YXBwaWQ9aGlnaGxhbmRlcjtzbT0xO3c9NTAwO2g9MjAw/http://media.zenfs.com/en/homerun/feed_manager_auto_publish_494/3da2941d2b6e5249f73bed9bd44fdbf3)

While we used this as a fun trick, it can be used for nefarious reasons. One way to workaround this issue is to [cryptographically sign your commits](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work). So that people can be sure that you have made the commits.