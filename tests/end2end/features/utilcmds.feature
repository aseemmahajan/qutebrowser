Feature: Miscellaneous utility commands exposed to the user.

    Background:
        Given I open data/scroll/simple.html
        And I run :tab-only

    ## :later

    Scenario: :later before
        When I run :later 500 scroll down
        Then the page should not be scrolled
        # wait for scroll to execture so we don't ruin our future
        And the page should be scrolled vertically

    Scenario: :later after
        When I run :later 500 scroll down
        And I wait 0.6s
        Then the page should be scrolled vertically

    # for some reason, argparser gives us the error instead, see #2046
    @xfail
    Scenario: :later with negative delay
        When I run :later -1 scroll down
        Then the error "I can't run something in the past!" should be shown

    Scenario: :later with humongous delay
        When I run :later 36893488147419103232 scroll down
        Then the error "Numeric argument is too large for internal int representation." should be shown

    ## :repeat

    Scenario: :repeat simple
        When I run :repeat 5 scroll-px 10 0
        And I wait until the scroll position changed to 50/0
        # Then already covered by above And

    Scenario: :repeat zero times
        When I run :repeat 0 scroll-px 10 0
        And I wait 0.01s
        Then the page should not be scrolled

    ## :run-with-count

    Scenario: :run-with-count
        When I run :run-with-count 2 scroll down
        Then "command called: scroll ['down'] (count=2)" should be logged

    Scenario: :run-with-count with count
        When I run :run-with-count 2 scroll down with count 3
        Then "command called: scroll ['down'] (count=6)" should be logged

    ## :message-*

    Scenario: :message-error
        When I run :message-error "Hello World"
        Then the error "Hello World" should be shown

    Scenario: :message-info
        When I run :message-info "Hello World"
        Then the message "Hello World" should be shown

    Scenario: :message-warning
        When I run :message-warning "Hello World"
        Then the warning "Hello World" should be shown

    # argparser again
    @xfail
    Scenario: :repeat negative times
        When I run :repeat -4 scroll-px 10 0
        Then the error "A negative count doesn't make sense." should be shown
        And the page should not be scrolled

    ## :debug-all-objects

    Scenario: :debug-all-objects
        When I run :debug-all-objects
        Then "*Qt widgets - *Qt objects - *" should be logged

    ## :debug-cache-stats

    Scenario: :debug-cache-stats
        When I run :debug-cache-stats
        Then "config: CacheInfo(*)" should be logged
        And "style: CacheInfo(*)" should be logged

    ## :debug-console

    @no_xvfb
    Scenario: :debug-console smoke test
        When I run :debug-console
        And I wait for "Focus object changed: <qutebrowser.misc.consolewidget.ConsoleLineEdit *>" in the log
        And I run :debug-console
        And I wait for "Focus object changed: *" in the log
        Then "initializing debug console" should be logged
        And "showing debug console" should be logged
        And "hiding debug console" should be logged
        And no crash should happen

    ## :repeat-command

    Scenario: :repeat-command
        When I run :scroll down
        And I run :repeat-command
        And I run :scroll up
        Then the page should be scrolled vertically

    Scenario: :repeat-command with count
        When I run :scroll down with count 3
        And I wait until the scroll position changed
        And I run :scroll up
        And I wait until the scroll position changed
        And I run :repeat-command with count 2
        And I wait until the scroll position changed to 0/0
        Then the page should not be scrolled

    Scenario: :repeat-command with not-normal command inbetween
        When I run :scroll down with count 3
        And I wait until the scroll position changed
        And I run :scroll up
        And I wait until the scroll position changed
        And I run :prompt-accept
        And I run :repeat-command with count 2
        And I wait until the scroll position changed to 0/0
        Then the page should not be scrolled
        And the error "prompt-accept: This command is only allowed in prompt/yesno mode, not normal." should be shown

    Scenario: :repeat-command with mode-switching command
        When I open data/hints/link_blank.html
        And I run :tab-only
        And I hint with args "all tab-fg"
        And I run :leave-mode
        And I run :repeat-command
        And I run :follow-hint a
        And I wait until data/hello.txt is loaded
        Then the following tabs should be open:
            - data/hints/link_blank.html
            - data/hello.txt (active)

    ## :debug-log-capacity

    Scenario: Using :debug-log-capacity
        When I run :debug-log-capacity 100
        And I run :message-info oldstuff
        And I run :repeat 20 message-info otherstuff
        And I run :message-info newstuff
        And I open qute:log
        Then the page should contain the plaintext "newstuff"
        And the page should not contain the plaintext "oldstuff"

   Scenario: Using :debug-log-capacity with negative capacity
       When I run :debug-log-capacity -1
       Then the error "Can't set a negative log capacity!" should be shown

    ## :debug-log-level / :debug-log-filter
    # Other :debug-log-{level,filter} features are tested in
    # unit/utils/test_log.py as using them would break end2end tests.

    Scenario: Using debug-log-level with invalid level
        When I run :debug-log-level hello
        Then the error "level: Invalid value hello - expected one of: vdebug, debug, info, warning, error, critical" should be shown

    Scenario: Using debug-log-filter with invalid filter
        When I run :debug-log-filter blah
        Then the error "filters: Invalid value blah - expected one of: statusbar, *" should be shown
