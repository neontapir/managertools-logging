# Intro

This Manager Tools Logging tool is designed for tech-savvy line managers who
spend a lot of time on the command line and would like an easy way to record
notes from Manager Tools practices. Today, the tool supports one-on-ones and
feedback.

# Requirements

The tool requires Ruby 2.0 and the Asciidoctor and Bundler gems.

# Usage

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

You can also provide feedback:

    $ ./feedback tony
    With feedback for Tony Stark, enter the following:
    Polarity: |none| negative
    Content: |none| When you try to provoke people in the team room, it makes
    bystanders uncomfortable. Can you do that differently next time?

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

    $ ./gen-overview-files
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

## The 'mt' script

I'm in the process of creating an omnibus script to call o3, feedback, et al, from one script. It works but has no help.

# Extensibility

In `lib/employee_folder.rb`, there is a variable called `root` which defines
where your data is stored.

If you want to add a new diary entry type, you will need to:

* create a new entry class in `lib`, using the naming convention `type + Entry`,
for example ObservationEntry for an observation
* in `lib\diary.rb`:
  - add a `require_relative` entry in `lib\diary.rb` for the new entry class
  - update `Diary::create_entry` in `lib\diary.rb` to recognize the new entry class
* create a new script in the root that utilizes that entry class

# License

I'd appreciate hearing about how you decided to use this software. That having
been said...

## The MIT License (MIT)

Copyright (c) 2015 Charles Durfee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

http://opensource.org/licenses/MIT
