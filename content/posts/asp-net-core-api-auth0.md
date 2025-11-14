---
title: "Securing ASP.NET Core APIs using Auth0"
date: 2021-10-09
slug: "asp-net-core-api-auth0"
tags: ["aspnet", "auth0", "oauth", "openid-connect", "oidc"]
---
# Introduction

Modern applications are complex and take many different forms: Web apps, mobile apps, desktop apps, CLI apps, other APIs, Bots, IoT apps, and so on. In this blog post we discuss what it takes for your API to let any app communicate with it securely via the OAuth 2.0 and OpenID Connect protocols.

By utilizing these standards, you can have a single Identity Provider protecting all of your apps. Allowing your users to sign into all of your apps using the same account, providing a seamless SSO (Single Sign On and Single Sign Out) experience. Another great benefit is you can easily allow 3rd party apps to connect to your APIs without compromising security.

# OAuth

## Overview and history of OAuth

OAuth is an open standard for autho

## Different actors in OAuth

## What's JWT

# OpenID Connect

1. Overview and history of OIDC
2. Access Token vs Id Token

# Authentication Flows

1. Authorization Code Flow
2. Authorization Code Flow + PKCE
3. Resource Owner Password Flow
4. Client Credentials Flow

# Choosing an OpenID Connect Provider

1. Implementing your own OpenID Connect Provider
2. Using an open source OpenID Connect Provider
3. Using a cloud-based OpenID Connect Provider

# Integrating ASP.NET Core API with Auth0

1. Overview of Auth0 and mapping concepts with OIDC
2. Integrate your API with Auth0
3. Test your API Authentication using Swagger
4. Where should we store user information
5. Using Auth0's API to onboard users
6. Role based authorization using Auth0
7. Permission based authorization using Auth0
8. Service to service communication

# Bonus: Custom Authorization Implementation

1. Role based authorization
2. Permission based authorization

# Related resources

1. [Kevin Dockx - Securing ASP.NET Core 3 with OAuth2 and OpenID Connect](https://app.pluralsight.com/library/courses/securing-aspnet-core-3-oauth2-openid-connect)
2. [Kevin Dockx - Securing Microservices in ASP.NET Core](https://app.pluralsight.com/library/courses/securing-microservices-asp-dot-net-core)
3. [What the Heck is OAuth?](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth)
