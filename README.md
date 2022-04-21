# Manager Tools Logging

## Intro

This Manager Tools Logging tool is designed for tech-savvy line managers who
spend a lot of time on the command line and would like an easy way to record
notes from Manager Tools practices. Today, the tool supports one-on-ones and
feedback.

## Requirements

The tool requires Ruby 2.0+ and the Asciidoctor and Bundler gems, among others.

### The 'mt' script

I created an omnibus script in Ruby to call the various functions from one script. Over time, it replaced some standalone scripts.

## Usage

    $ bundle install # ... installs all the gems required

    [ look at lib/settings.rb and create a data/config.yml file ]

    $ ./mt new-hire -t avengers -n "Tony Stark"
    Creating data/avengers/tony-stark

    Reviewing data/avengers/tony-stark/overview.adoc... generating

Here, I'm making a `one-on-one` entry. Note that I can specify a partial name
to look up a person.

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

Notice a couple of things here. I used the `new-hire` command to create some
infrastructure for Tony. However, when I didn't do that with Steve, the command
prompted me for the data it needed. Here are the files that were created:

    $ tree data
    data
    └── avengers
        ├── steve-rogers
        │   └── log.adoc
        │   └── overview.adoc
        └── tony-stark
            ├── log.adoc
            └── overview.adoc

These commands store their data as Asciidoc files. I can create an HTML export
of the log file pretty easily:

    $ ./mt report steve

There are a number of types of diary entries. You can also provide `feedback`:

    $ ./mt feedback tony
    With feedback for Tony Stark, enter the following:
    Polarity: |positive| negative
    Content: |none| When you try to provoke people in the team room, it makes
    bystanders uncomfortable. Can you do that differently next time?

You can make `observations` about direct reports. Observations are an entry type
for adding content to a log which does not come from an interaction with the
direct report.

    $ ./mt observation steve
    Enter your observation for Steve Rogers:
    Content: |none| My manager came to me after seeing Steve getting some basic
    computer help. She asked if computer training was part of his annual goal
    plan.

You can also make observations about `multiple people at once`. You can use
`relative time specification` in date fields.

    $ ./mt obs rogers stark
    Enter your observation:
    Effective date: |2020-01-25 10:15:50 -0700| yesterday
    Content: |none| Came into the office early to help set up for the team
    meeting

When I enter that, the following entry is put into their log files.

    === Observation (January 24, 2020, 12:00 PM)
    Applies to::
      Steve Rogers, Tony Stark
    Content::
      Came into the office early to help set up for the team meeting

Other entry options not covered here are:

- `goal`, for recording goals or individual development plans
- `interview` (which uses a team called `zzz_candidates`)
- `perf`, which uses a performance checkpoint template
- `pto`, for recording time out of office
- `team`, which acts like the multiple people entry above, but it auto-selects
  all members of the specified team(s)

After our examples, this is what `data/avengers/tony-stark/log.adoc` contains:

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

    === Observation (January 24, 2020, 12:00 PM)
    Applies to::
      Steve Rogers, Tony Stark
    Content::
      Came into the office early to help set up for the team meeting

Notice that the command did some word-wrapping for you.

I manually created a `team-directory.adoc` file:

    = Team Directory

    == Team Avengers

    include::data/avengers/steve-rogers/overview.adoc[]

    include::data/avengers/tony-stark/overview.adoc[]

And was able to generate a nice-looking HTML file by running Asciidoctor against
it:

    $ asciidoctor team-directory.adoc
    $ ls team-directory.html
    team-directory.html

If you want a report on a particular team member, use the `report` command, which
combines the overview and log files into a nice HTML file. The overview template
assumes that there is a file called "headshot.jpg" in each person's folder, and
displays it at the top right corner of the file. The `report-team` command will
combine all members of the team into a single web page.

Other commands include:

- `move`, for moving people to a different team
- `depart`, for moving people to the `zzz_departed` folder

The advantage of using these move commands is that it will add a diary entry
indicating the team change.

- `last`, for displaying the person's last diary entry
- `open`, for loading the diary log file into the default text editor

Of course, who would want to do that manually? There's also a `Rakefile` that
contains some of these commands. (If you followed along and now try to run
`rake`, you'll have problems because the test data uses the Avengers too. The
test suite assumes that it can create and destroy Avengers data at will.)

### Lookups

The script finds people by looking at a string containing the team name and the
individual's name, then finding the first match by folder and person name in
alphabetical order. This is the reason that the candidates folder is prefaced
with "zzz\_", in order to make it last in the search order.

This algorithm can be problematic in some edge cases. For example, I have a
"Tommy" team, and that person has a person named Tom on it. If I just reference
"tom", I get Andy, the person on the Tommy team who comes first in alphabetical
order. In order to reference Tom, I have to say, "tom-". So far, this has not
been enough of an issue for me to correct.

## Extensibility

### Changing where data is stored

In the `config.yaml` file, there is a variable called `data_root` which defines
where your data is stored. It's used by `lib\settings.rb`. The variable
`candidates_root` determines in which folder interviews are recorded.

People who no longer report to me are put into a team folder called
"`zzz_departed`". The script will still find them as normal.

### Adding a new entry type

If you want to add a new diary entry type, you will need to create a new entry
class in `lib`, using the naming convention `type + Entry`, for example
`ObservationEntry` for an observation. It will inherit from `DiaryEntry`.

After creating a new entry type according to the subsection, you need to update
`lib\manager_tools_cli.rb` to parse your new entry type. It makes heavy use
of the `Thor` gem to define subcommands `mt` understands. Use the existing types
as a guide. For simple cases, "invoke module directly" is the right option. For
more complicated cases, create a custom command.

### Adding a new command

Actions are handled by commands. There is an `MtCommand` class that implements
a Command pattern using the method `command`. To add a command, create a new
inheritor, then add the command to `lib\manager_tools_cli.rb`, which handles
all the program interaction with the CLI.

#### Creating the new entry type

Looking at `ObservationEntry` as an example, you will see there are three methods
to customize:

    require_relative '../diary_date_element'
    require_relative '../diary_element'
    require_relative 'diary_entry'

    # Template for an observation
    class ObservationEntry < DiaryEntry
      # generates the interactive prompt string
      def prompt(name)
        personalized = name[','] ? '' : " for #{name}"
        "Enter your observation#{personalized}:"
      end

      # define the items included in the entry
      def elements
        result = [
          DiaryDateElement.new(:datetime, 'Effective date'),
          DiaryElement.new(:content),
        ]
        with_applies_to(result)
      end

      # render the entry into a string suitable for file insertion
      def entry_banner
        'Observation'
      end
    end

The `prompt` text is displayed at the beginning of the recording. The
`personalized` variable exists to gracefully handle situations where
multiple people are specified.

Each element in the `elements` becomes a question that is asked of the
user. This example shows two entries, a date and a string. The difference
is that dates apply parsing to interpret the date given.

In the `datetime` entry, the prompt is specified in the second argument. If
there were a third argument, it would be the default value. For dates, that's
now. For strings, it's "None". The `content` entry shows that the last two
arguments are optional.

The `to_s` method is what gets written to the log file, and the implementation
inherited from `DiaryEntry` uses the results of the `render` method. The
`entry_banner` titles the diary entry.

## Usage Hints

In cases where I want to quote material, I will often use the script to fill in
values. I then use a text editor like Atom or VS Code to add the quoted material,
like a chat room transcript or email.

## Running tests

Use `bundle exec rake rspec`.
