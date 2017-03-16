# Intro

This Manager Tools Logging tool is designed for tech-savvy line managers who
spend a lot of time on the command line and would like an easy way to record
notes from Manager Tools practices. Today, the tool supports one-on-ones and
feedback.

# Requirements

The tool requires Ruby 2.0+ and the Asciidoctor and Bundler gems, among others.

## The 'mt' script

I created an omnibus script to call the various functions from one script. Over
time, it replaced some standalone scripts.

# Usage

    $ bundle install # ... installs all the gems required

    $ ./mt new-hire -t avengers -n "Tony Stark"
    Creating data/avengers/tony-stark

    Reviewing data/avengers/tony-stark/overview.adoc... generating

    $ ./mt o3 tony
    For your 1:1 with Tony Stark, enter the following:
    Location: |none| Avengers Tower
    Notes: |none| Tony told me about the altercation with Steve today. I
    suggested a less confrontation approach.
    Actions: |none| See if HR offers anger management classes.

    $ ./mt o3 steve
    Team: Avengers
    First: Steve
    Last: Rogers
    Creating data/avengers/steve-rogers
    For your 1:1 with Steve Rogers, enter the following:
    Location: |none| Avengers Tower
    Notes: |none| Steve was upset by Tony trying to provoke him in the team room.
    Actions: |none|

Notice a couple of things here. I used the `new-hire` script to create some
infrastructure for Tony. However, when I didn't do that with Steve, the script
prompted me for the data it needed. Here are the files that were created:

    $ tree data
    data
    └── avengers
        ├── steve-rogers
        │   └── log.adoc
        └── tony-stark
            ├── log.adoc
            └── overview.adoc

These scripts store their data as Asciidoc files. Notice that Tony has an
overview file, which was created by the new hire script.

You can also provide `feedback`:

    $ ./mt feedback tony
    With feedback for Tony Stark, enter the following:
    Polarity: |positive| negative
    Content: |none| When you try to provoke people in the team room, it makes
    bystanders uncomfortable. Can you do that differently next time?

You can make observations about direct reports. Observations are an entry type
for adding content to a log which does not come from an interaction with the
direct report.

    $ ./mt observation steve
    Enter your observation for Steve Rogers:
    Content: |none| My manager came to me after seeing Steve getting some basic
    computer help. She asked if computer training was part of his annual goal
    plan.

Other entry options not covered here are:

  - `interview` (which uses a team called `zzz_candidates`)
  - `team meeting`, which propagates the content to the logs of all members of
  the team

After our examples, this is what data/avengers/tony-stark/log.adoc contains:

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

Notice that the script did some word-wrapping for you.

I can generate missing team files using `gen-overview-files`.

    $ ./mt gen-overview-files
    Generating avengers Steve Rogers...
    Generating avengers Tony Stark...

I manually created a team-directory.adoc file:

    = Team Directory

    == Team Avengers

    include::data/avengers/steve-rogers/overview.adoc[]

    include::data/avengers/tony-stark/overview.adoc[]

And was able to generate a nice-looking HTML file by running Asciidoctor against
it:

    $ asciidoctor team-directory.adoc
    $ ls team-directory.html
    team-directory.html

If you want a report on a particular team member, use the `report` script, which
combines the overview and log files into a nice HTML file. The overview template
assumes that there is a file called "headshot.jpg" in each person's folder, and
displays it at the top right corner of the file.

Of course, who would want to do that manually? There's also a Rakefile that
contains some of these commands. (If you followed along and now try to run
`rake`, you'll have problems because the test data uses the Avengers too. The
test suite assumes that it can create and destroy Avengers data at will.)

## Lookups

The script finds people by looking at a string containing the team name and the
individual's name, then finding the first match in alphabetical order. This is
the reason that the candidates folder is prefaced with "zzz_", in order to make
it last in the search order.

This algorithm can be problematic in some edge cases. For example, I have a
"Tommy" team, and that person has a person named Tom on it. If I just reference
"tom", I get Andy, the person on the Tommy team who comes first in alphabetical
order. In order to reference Tom, I have to say, "tom-". So far, this has not
been enough of an issue for me to correct.

Another issue I've discovered is that the lookup logic fails if there is a dash
in the team name. Again, this has not been a high enough priority for me to
fix.

# Extensibility

In `lib/employee_folder.rb`, there is a variable called `root` which defines
where your data is stored. The variable `candidates_root` determines in which
folder interviews are recorded.

If you want to add a new diary entry type, you will need to:

- create a new entry class in `lib`, using the naming convention `type + Entry`,
for example ObservationEntry for an observation

- in `lib\diary.rb`, add a `require_relative` entry in `lib\diary.rb` for the
new entry class

- create a new script in the root that utilizes that entry class

# Usage Hints

I manually move the folders of people who no longer report to me to a team
folder called "zzz_departed". The script will still find them as normal. You can
also use the same approach when people change teams. It happens infrequently
enough for me that I didn't automate it.

# Contributing

- Fork this repository
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create a new pull request
