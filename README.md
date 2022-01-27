# Twitter Memories

[https://throwback.cc](https://throwback.cc)

I created this app on a whim using my cousin's windows laptop which had Rails 5 installed. There's a lot of room for improvement as I only built it within hours and in quite a rush.

I did not expect this project to blow up and get viral that's why I'm struggling a bit now on how to sustain and scale this app.

Currently, I'm planning to rebuild this app with Rails 6 as I need to refactor a whole lot of code and use service objects for efficiency.

## Install

### Clone the repository

```shell
git clone git@github.com:youngestbllnr/twitter-memories.git
cd project
```

### Check your Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.7.2`

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle && yarn
```

### Initialize the database

```shell
rails db:migrate
```

## Serve

```shell
rails s
```
