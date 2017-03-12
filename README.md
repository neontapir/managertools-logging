# Intro

This Manager Tools Logging tool is designed for tech-savvy line managers who spend a lot of time on the command line and would like an easy way to record notes from Manager Tools practices. Today, the tool supports one-on-ones and feedback.

# Requirements

The tool requires Ruby 2.0 and the Asciidoctor and Bundler gems.

# Usage

```
$ bundle install # ... installs all the gems required
$ ./new-hire -t avengers -n "Tony Stark"
Creating data/avengers/tony-stark

Reviewing data/avengers/tony-stark/overview.adoc... generating
$ ./o3 tony
For your 1:1 with Tony Stark, enter the following:
Location: |none| Avengers Tower
Notes: |none| Tony told me about the altercation with Steve today. I
suggested a less confrontation approach.
Actions: |none| See if HR offers anger management classes.
$ ./o3 steve
Team: Avengers
First: Steve
Last: Rogers
Creating data/avengers/steve-rogers
For your 1:1 with Steve Rogers, enter the following:
Location: |none| Avengers Tower
Notes: |none| Steve was upset by Tony trying to provoke him in the team room.
Actions: |none|
```

Notice a couple of things here. I used the `new-hire` script to create some infrastructure for Tony. However, when I didn't do that with Steve, the script prompted me for the data it needed. Here are the files that were created:

```
$ tree data
data
└── avengers
    ├── steve-rogers
    │   └── log.adoc
    └── tony-stark
        ├── log.adoc
        └── overview.adoc
```

These scripts store their data as Asciidoc files. Notice that Tony has an overview file, which was created by the new hire script.

You can also provide `feedback`:

```
$ ./feedback tony
With feedback for Tony Stark, enter the following:
Polarity: |positive| negative
Content: |none| When you try to provoke people in the team room, it makes
bystanders uncomfortable. Can you do that differently next time?
```

Other options not covered here are `interview` (which uses a team called `candidates`) and `team meeting`.

After our examples, this is what data/avengers/tony-stark/log.adoc contains:

```
== One-on-One (July 29, 2015,  2:49 PM)
Location::
  Avengers Tower
Notes::
  Tony told me about the altercation with Steve today. I suggested a less
  confrontation approach.
Actions::
  See if HR offers anger management classes.

== Feedback (July 29, 2015,  3:02 PM)
Polarity::
  negative
Content::
  When you try to provoke people in the team room, it makes bystanders
  uncomfortable. Can you do that differently next time?
```

Notice that the script did some word-wrapping for you.

I can generate missing team files using `gen-overview-files`.

```
$ ./gen-overview-files
Generating avengers Steve Rogers...
Generating avengers Tony Stark...
```

I manually created a team-directory.adoc file:

```
= Team Directory

== Team Avengers

include::data/avengers/steve-rogers/overview.adoc[]

include::data/avengers/tony-stark/overview.adoc[]
```

And was able to generate a nice-looking HTML file by running Asciidoctor against it:

```
$ asciidoctor team-directory.adoc
$ ls team-directory.html
team-directory.html
```

If you want a report on a particular team member, use the `report` script, which combines the overview and log files into a nice HTML file. The overview template assumes that there is a file called "headshot.jpg" in each person's folder, and displays it at the top right corner of the file.

Of course, who would want to do that manually? There's also a Rakefile that contains some of these commands. (If you followed along and now try to run `rake`, you'll have problems because the test data uses the Avengers too. The test suite assumes that it can create and destroy Avengers data at will.)

# Extensibility

In `lib/employee_folder.rb`, there is a variable called `root` which defines where your data is stored. The variable `candidates_root` determines in which folder interviews are recorded.

If you want to add a new diary entry type, you will need to:

- create a new entry class in `lib`, using the naming convention `type + Entry`, for example ObservationEntry for an observation

- in `lib\diary.rb`, add a `require_relative` entry in `lib\diary.rb` for the new entry class

- create a new script in the root that utilizes that entry class

# Usage Hints

I manually move people who no longer report to me to a team called "departed". The script will still find them as normal. You can also use the same approach when people change teams. It happens infrequently enough for me that I didn't automate it.

# Contributing

- Fork this repository
- Create your feature branch (git checkout -b my-new-feature)
- Commit your changes (git commit -am 'Add some feature')
- Push to the branch (git push origin my-new-feature)
- Create a new pull request
