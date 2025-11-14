---
title: "Getting a code signing certificate for a company in Iraq"
date: 2020-04-16
slug: "code-signing-certificate-iraq"
tags: ["code-signing", "iraq"]
---
If your company is based in one of the developed countries, chances are you won't have much of a problem. It would take a week at most to get a code signing certificate. However, If your company is based in a country like Iraq, which doesn't have an up-to-date online-accessible list of its companies, then you are going to have a harder time. Fortunately, this guide makes the process much easier and faster. The documents might vary by country, but the certificate authority support team will help you go through the process.

Before we start I want to define some terms, because many people (like myself when I started out) are not familiar with the territory. Nate McMaster explains them very well in his [blog post](https://natemcmaster.com/blog/2018/07/02/code-signing/):

> - [***Code signing***](https://en.wikipedia.org/wiki/Code_signing) means applying a digital signature to the executable binaries (for example `McMaster.Extensions.CommandLineUtils.dll`). This signature confirms the authenticity and integrity of the files.
> - ***Authenticity*** proves the files came from me, Nathan McMaster, and not someone pretending to be me.
> - ***Integrity*** also proves the files have not been altered by anyone since I made them.
>
> - [A ***certificate***](https://en.wikipedia.org/wiki/Public_key_certificate) contains public information about me and [a public key](https://en.wikipedia.org/wiki/Public-key_cryptography). Anyone can see my certificate, but only I can produce a signature with it because I keep secret the private key, which matches with the public key in the certificate. Anyone can create a certificate for free on their own, but Windows apps won’t treat this as “trusted” unless you get a certificate from a CA.
>
> - [A ***certificate authority*** (CA)](https://en.wikipedia.org/wiki/Certificate_authority) is an entity that issues certificates. In my case, I worked with [DigiCert](https://digicert.com/) to get a certificate. This certificate, unlike a self-created cert, contains additional information which proves DigiCert gave me the certificate.

What are the benefits of code signing certificates? Well, I had the same question. And I got two good reasons:

<?# Twitter 1210259160908075008 /?>

<?# Twitter 1210259181854449672 /?>

And code signing certificates come in two flavors: *Standard Code Signing Certificate* and *Extended Validation (EV) Code Signing Certificates*. *EV Code Signing Certificates* are more expensive and harder to get but they provide with instant trust with Microsoft Smart Screen. But they also require either hardware USB tokens or and [_Hardware Security Module_](https://en.wikipedia.org/wiki/Hardware_security_module) to sign software. You can also store them in something like Azure Key Vault. In my limited experience, the standard one is enough and gives you less headache to deal with.

It took us more than 5 months to get a code signing certificate. Partly because we had no experience with the whole process and partly because our company is based in Iraq. One of our mistakes was that we asked for a EV code signing certificate at first, which made the validation process much harder.

### 1. Get a [D&B](https://en.wikipedia.org/wiki/Data_Universal_Numbering_System) Number

The official website of D&B does not open in Iraq and to my knowledge D&B doesn't have a branch in Iraq. Fortunately, you can go to http://upik.de/en and get D&B number. It makes your life much easier as all of the CAs I have talked to consider them a trusted source. They will ask you a few questions and will require documents to prove your company is legitimate. We sent them:

- Company establishment certificate 
- Decision of approval for a company establishment.

Because these documents were in Kurdish (our company is based in Kurdistan region of Iraq), we translated both documents and send scanned and sent both the translated version and the original version.

The validation process can take up to 30 days. However, ours took about a week.

### 2. Find a CA that can work with companies in Iraq

Not all of the CAs can issue certificates for companies in Iraq. They say it's because sanctions and things like that. But some companies have branches in Middle East and so they will happily issue a certificate for you. Talk with their sales or customer support to confirm that.

And make sure the CA is partnered to whatever operating system vendor you care about. Here is [the list of CAs partnered with Microsoft](https://docs.microsoft.com/en-us/security/trusted-root/participants-list).

### 3. Go through the validation process

In the validation process, they will ask you some questions about your company name, address, and field of work. Make sure to write the full legal name when they ask for company name.

They will also ask you for documents to prove the answers you've sent them. We sent these documents:

- Decision of approval for a company establishment.
- Our lease contract

Because you already have a D&B number, things should go on smoothly. The CAs are usually helpful and try their best to help you go through the process.

## FAQ

Before starting the process I had these questions:

1. **Should I get the EV or the standard code signing certificate?**
   To be honest the standard code signing certificate seems enough. We signed our app using a standard code signing certificate and Windows didn't complain even on the first download of the app.
2. **Can I sign multiple apps with the same certificate?**
   Yes! The certificate is for your company, not a specific app. So you can sign as many apps as you need. Be careful though, if your certificate gets into the hands of malicious people they might sign malware with it and the CA  will be forced to revoke the certificate.
3. **Can an individual get a code signing certificate?**
   Yes! Although I am not familiar with the process.