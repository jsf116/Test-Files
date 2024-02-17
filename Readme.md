# NAME

**Test::Files** - A [Test::Builder](https://metacpan.org/pod/Test::Builder)
based module to ease testing with files and dirs.

In general, the following can be tested:

- If the contents of the file being tested match the expected pattern.

- If the file being tested is identical to the expected file in regard to contents, or size, or existence.

  If necessary, some parts of the contents can be excluded from the comparison.

- If the directory being tested contains all expected files.

- If the files in the directory being tested are identical to the files in the reference directory
in regard to contents, or size, or existence.

  If necessary, some files as well as some parts of contents can be excluded from the comparison.

- If all files in the directory being tested fulfill certain requirements.

# SYNOPSIS
```perl
    use Path::Tiny qw( path );
    use Test::Files;

    my $got_file       = path( 'path' )->child( qw( got file ) );
    my $reference_file = path( 'path' )->child( qw( reference file ) );
    my $got_dir        = path( 'path' )->child( qw( got dir ) );
    my $reference_dir  = path( 'path' )->child( qw( reference dir with expected stuff ) );
    my @file_list      = qw( expected file );
    my ( $content_check, $expected, $filter, $options );

    plan( 22 );

    # Simply compares file contents to a string:
    $expected = "contents\nof file";
    file_ok( $got_file, $expected, 'got file has expected contents' );

    # Two identical variants comparing file contests to a string ignoring differences in time stamps:
    $expected = "filtered contents\nof file\ncreated at 00:00:00";
    $filter   = sub { shift =~ s/ \b (?: [01] \d | 2 [0-3] ) : (?: [0-5] \d ) : (?: [0-5] \d ) \b /00:00:00/grx };
    $options  = { FILTER => $filter };
    file_ok       ( $got_file, $expected, $options, "'$got_file' has contents expected after filtering" );
    file_filter_ok( $got_file, $expected, $filter,  "'$got_file' has contents expected after filtering" );

    # Simply compares two file contents:
    compare_ok( $got_file, $reference_file, 'files are the same' );

    # Two identical variants comparing contents of two files ignoring differences in time stamps:
    $filter  = sub { shift =~ s/ \b (?: [01] \d | 2 [0-3] ) : (?: [0-5] \d ) : (?: [0-5] \d ) \b /00:00:00/grx };
    $options = { FILTER => $filter };
    compare_ok       ( $got_file, $reference_file, $options, 'files are almost the same' );
    compare_filter_ok( $got_file, $reference_file, $filter,  'files are almost the same' );

    # Verifies if both got file and reference file exist:
    $options = { EXISTENCE_ONLY => 1 };
    compare_ok( $got_file, $reference_file, $options, 'both files exist' );

    # Verifies if got file and reference file have identical size:
    $options = { SIZE_ONLY => 1 };
    compare_ok( $got_file, $reference_file, $options, 'both files have identical size' );

    # Verifies if the directory has all expected files (not recursively!):
    $expected = [ qw( files got_dir must contain ) ];
    dir_contains_ok( $got_dir, $expected, 'directory has all files in list' );

    # Two identical variants doing the same verification as before,
    # but additionally verifying if the directory has nothing but the expected files (not recursively!):
    $options = { SYMMETRIC => 1 };
    dir_contains_ok     ( $got_dir, $expected, $options, 'directory has exactly the files in the list' );
    dir_only_contains_ok( $got_dir, $expected,           'directory has exactly the files in the list' );

    # The same as before, but recursive:
    $options = { RECURSIVE => 1, SYMMETRIC => 1 };
    dir_contains_ok( $got_dir, $expected, $options, 'directory and its subdirectories have exactly the files in the list' );

    # The same as before, but ignoring files, which names do not match the required pattern (file "must" will be skipped):
    $options = { NAME_PATTERN => '^[cfg]', RECURSIVE => 1, SYMMETRIC => 1 };
    dir_contains_ok(
      $got_dir, $expected, $options,
      "directory and its subdirectories have exactly the files in the list except of file 'must'"
    );

    # Compares two directories by comparing file contents (not recursively!):
    compare_dirs_ok(
      $got_dir, $reference_dir,
      "all files from '$got_dir' are the same in '$reference_dir' (same names, same contents), subdirs are skipped"
    );

    # The same as before, but subdirectories are considered, too:
    $options = { RECURSIVE => 1 };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options, "all files from '$got_dir' and its subdirs are the same in '$reference_dir'"
    );

    # The same as before, but only file sizes are compared:
    $options = { RECURSIVE => 1, SIZE_ONLY => 1 };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options, "all files from '$got_dir' and its subdirs have same sizes in '$reference_dir'"
    );

    # The same as before, but only file existence is verified:
    $options = { EXISTENCE_ONLY => 1, RECURSIVE => 1 };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options, "all files from '$got_dir' and its subdirs exist in '$reference_dir'"
    );

    # The same as before, but only files with base names starting with 'A' are considered:
    $options = { EXISTENCE_ONLY => 1, NAME_PATTERN => '^A', RECURSIVE => 1 };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options,
      "all files from '$got_dir' and its subdirs with base names starting with 'A' exist in '$reference_dir'"
    );

    # The same as before, but the symmetric verification is requested:
    $options = { EXISTENCE_ONLY => 1, NAME_PATTERN => '^A', RECURSIVE => 1, SYMMETRIC => 1 };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options,
      "all files from '$got_dir' and its subdirs with base names starting with 'A' exist in '$reference_dir' and vice versa"
    );

    # Two identical version of comparison of two directories by file contents,
    # whereas these contents are first filtered so that time stamps in form of 'HH:MM:SS' are replaced by '00:00:00'
    # like in examples for file_filter_ok and compare_filter_ok:
    $filter  = sub { shift =~ s/ \b (?: [01] \d | 2 [0-3] ) : (?: [0-5] \d ) : (?: [0-5] \d ) \b /00:00:00/grx };
    $options = { FILTER => $filter };
    compare_dirs_ok(
      $got_dir, $reference_dir, $options,
      "all files from '$got_dir' are the same in '$reference_dir', subdirs are skipped, differences of time stamps ignored"
    );
    compare_dirs_filter_ok(
      $got_dir, $reference_dir, $filter,
      "all files from '$got_dir' are the same in '$reference_dir', subdirs are skipped, differences of time stamps ignored"
    );

    # Verifies if all plain files in directory and its subdirectories contain the word 'good'
    # (take into consideration the -f test below excluding special files from comparison!):
    $content_check = sub { my ( $file ) = @_; ! -f $file or path( $file )->slurp =~ / \b good \b /x };
    $options       = { RECURSIVE => 1 };
    find_ok( $got_dir, $content_check, $options, "all files from '$got_dir' and subdirectories contain the word 'good'" );
```
# DESCRIPTION

This module is like [Test2::V0](https://metacpan.org/pod/Test2::V0) or
[Test::Expander](https://metacpan.org/pod/Test::Expander),
in fact you should use that first as shown above.
It supports comparison of files and directories in different ways.

Any file or directory passed to functions of this module can be both a string or an object of
[Path::Tiny](https://metacpan.org/pod/Path::Tiny).

Though the test names i.e. the last parameter of every function is optional,
you should provide a name of each test for a better maintainability.

You should follow the lead of the ["SYNOPSIS"](#synopsis) examples and use [Path::Tiny](https://metacpan.org/pod/Path::Tiny) or,
if you prefer, [File::Spec](https://metacpan.org/pod/File::Spec).
This makes it much more likely that your tests will pass on a different operating system.

All of the contents comparison routines provide diff diagnostic output when they report failure.
The diff output style can be changed using the option **STYLE** (see below).

The filter function receives each line of each file.
It may perform any necessary transformations (like excising dates),
then it must return the line in (possibly) transformed state.
For example, the first filter of [Phil Crow](https://metacpan.org/author/PHILCROW), the creator of this module was
```perl
    sub chop_dates {
      my $line = shift;
      $line =~ s/\d{4}(.\d\d){5}//g;
      return $line;
    }
```
This removes all strings like 2003.10.14.14.17.37.
Everything else is unchanged and failing tests started passing when they should.
If you want to exclude the line from consideration, return empty string or **undef**.

## FUNCTIONS

### file\_ok( $got\_file, $expected\_string,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $test\_name )

### file\_ok( $got\_file, $expected\_string, \\%options, $test\_name )

Compares the contents of a file **$got\_file** to a string **$expected\_string**.

In the generic form (i.e. if the 3rd parameter **\\%options** is passed and contains the key **FILTER**)
**file\_ok** provides the same functionality as **file\_filter\_ok**.

#### Supported options

- **FILTER**

    Code reference providing filtering of file contents before comparison.
    The only expected parameter is the current line from the file contents, the return value replaces this line.
    If the return value is undefined, empty string is applied instead.
    Line breaks are neither removed nor added after the execution.

    Defaults to **undef** i.e. no filtering is provided.

- All options supported by [Text::Diff](https://metacpan.org/pod/Text::Diff)
except of **FILENAME\_A** and **FILENAME\_B**.

    The most useful of them is **STYLE** defining the style of output for content differences.
    Defaults to **Unified**.

### file\_filter\_ok( $got\_file, $expected\_string, \\&filter\_func, $test\_name )

Works like **file\_ok** with the option **FILTER** i.e. compares the contents of a file to a string,
but filters the file first. The string contents must be filtered before if necessary.

This function is deprecated and stays for backward compatibility reasons only.

### compare\_ok( $got\_file, $reference\_file,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $test\_name )

### compare\_ok( $got\_file, $reference\_file, \\%options, $test\_name )

Compares two files.

In the generic form (i.e. if the 3rd parameter **\\%options** is passed and contains the key **FILTER**)
**compare\_ok** provides the same functionality as **compare\_filter\_ok**.

#### Supported options

- **EXISTENCE\_ONLY**

    Boolean. If set to **true**, only existence of both **$got\_file** and **$reference\_file** is compared.

    Defaults to **false**.

- **FILTER**

    Code reference providing filtering of file contents before comparison and
    applied to both **$got\_file** and **$reference\_file**.
    The only expected parameter is the current line from the file contents, the return value replaces this line.
    If the return value is undefined, empty string is applied instead.
    Line breaks are neither removed nor added after the execution.

    Defaults to **undef** i.e. no filtering is provided.

- **SIZE\_ONLY**

    Boolean. If set to **true** and the options **EXISTENCE\_ONLY** is not set to **true**,
    **$got\_file** and **$reference\_file** are compared by size only.

    Defaults to **false**.

- All options supported by [Text::Diff](https://metacpan.org/pod/Text::Diff)
except of **FILENAME\_A** and **FILENAME\_B**.

    The most useful of them is **STYLE** defining the style of output for content differences.
    Defaults to **Unified**.

### compare\_filter\_ok( $got\_file, $reference\_file, \\&filter\_func, $test\_name )

Works like **compare\_ok** with option **FILTER** i.e. compares the contents of two files,
but sends each line through a filter so things that shouldn't count against success can be stripped.

This function is deprecated and stays for backward compatibility reasons only.

### dir\_contains\_ok( $got\_dir, \\@file\_list, $test\_name )

### dir\_contains\_ok( $got\_dir, \\@file\_list, \\%options, $test\_name )

Verifies a directory for the presence of a list files. Symlinks are not followed.
Subdirectories are not involved in the verification, but files located therein are considered
if recursive appraoch is required (see the option **RECURSIVE** below).
Special files like named pipes are involved in the verification only if the sole file existence is required
(see the option **EXISTENCE\_ONLY** below), otherwise they are skipped and reported as error.

In the generic form i.e. if the 3rd parameter **\\%options** is passed and
contains the key **SYMMETRIC** set to **true**, **dirs\_contains\_ok** provides the same functionality
as **dir\_contains\_only\_ok**.

#### Supported options

- **EXISTENCE\_ONLY**

    Boolean. If set to **true**, only existence of files in **$got\_dir** is tested.

    Defaults to **false**.

- **NAME\_PATTERN**

    String containing RegEx. Files with base names not matching this RegEx will be skipped.

    Defaults to the dot sign (**.**) i.e. no file will be skipped.

- **RECURSIVE**

    Boolean. If set to **true**, subdirectories of **$got\_dir** will be checked, too.

    Defaults to **false**.

- **SYMMETRIC**

    Boolean. If set to **true**, additionally verifies if all files from **$got\_dir** are listed in **@file\_list**.

    Defaults to **false**.

### dir\_contains\_only\_ok( $got\_dir, \\@file\_list, $test\_name )

Works like **dir\_contains\_ok** with option **SYMMETRIC** set to **true** i.e.
checks directory without following symlinks to ensure
that the listed files are present and that they are the only ones present.

This function is deprecated and stays for backward compatibility reasons only.

### compare\_dirs\_ok( $got\_dir, $reference\_dir,&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $test\_name )

### compare\_dirs\_ok( $got\_dir, $reference\_dir, \\%options, $test\_name )

Compares (not following symlinks!) all files in two directories reporting differences.

In the generic form (i.e. if the 3rd parameter **\\%options** is passed and contains the key **FILTER**)
**compare\_dirs\_ok** provides the same functionality as **compare\_dirs\_filter\_ok**.

#### Supported options

- **EXISTENCE\_ONLY**

    Boolean. If set to **true**, only checks if every file from **$reference\_dir** is found in **$got\_dir**.

    Defaults to **false**.

- **FILTER**

    Code reference providing filtering of file contents before comparison and
    applied to files from both **$got\_dir** and **$reference\_dir**.
    The only expected parameter is the current line from the file contents, the return value replaces this line.
    If the return value is undefined, empty string is applied instead.
    Line breaks are neither removed nor added after the execution.

    Defaults to **undef** i.e. no filtering is provided.

- **NAME\_PATTERN**

    String containing RegEx.
    Files with base names not matching this RegEx will be skipped both in **$got\_dir** and **$reference\_dir**.

    Defaults to the dot sign (**.**) i.e. no file will be skipped.

- **RECURSIVE**

    Boolean. If set to **true**, subdirectories of both **$got\_dir** and **$reference\_dir** will be checked, too.

    Defaults to **false**.

- **SIZE\_ONLY**

    Boolean. If set to **true** and the options **EXISTENCE\_ONLY** is not set to **true**,
    files from **$got\_dir** and **$reference\_dir** are compared by size only.

    Defaults to **false**.

- **SYMMETRIC**

    Boolean. If set to **true**, additionally verifies if all files from **$got\_dir** exist in **$reference\_dir**, too.

    Defaults to **false**.

- All options supported by [Text::Diff](https://metacpan.org/pod/Text::Diff)
except of **FILENAME\_A** and **FILENAME\_B**.

    The most useful of them is **STYLE** defining the style of output for content differences.
    Defaults to **Unified**.

### compare\_dirs\_filter\_ok( $got\_dir, $reference\_dir, \\&filter\_func, $test\_name )

Works like **compare\_dirs\_ok** with option **FILTER** i.e. calls a filter function on each line of every file
allowing you to exclude or alter some text to avoid spurious failures (like timestamp disagreements).

This function is deprecated and stays for backward compatibility reasons only.

### find\_ok( $got\_dir, \\&content\_check\_func, \\%options, $test\_name )

Verifies if the condition passed as code reference **\\&content\_check\_func** is true for all files in directory **$got\_dir**.
The code reference returning boolean is called for any type of file except of directory
i.e. for symlinks, devices, etc and the only parameter is the full-qualified file name.
If you want to consider plain files only, you must apply the test operator **-f** to the parameter.

#### Supported options

- **RECURSIVE**

    Boolean. If set to **true**, subdirectories of **$got\_dir** will be checked, too.

    Defaults to **false**.

# SEE ALSO

Consult [Test::Simple](https://metacpan.org/pod/Test::Simple), [Test2::V0](https://metacpan.org/pod/Test2::V0),
and [Test::Builder](https://metacpan.org/pod/Test::Builder) for more testing help.
This module really just adds functions to what [Test2::V0](https://metacpan.org/pod/Test2::V0) does.
As recommended by the author of [Test::More](https://metacpan.org/pod/Test::More)
and [Test2::V0](https://metacpan.org/pod/Test2::V0), the latter module should be preferred,
that's why [Test::More](https://metacpan.org/pod/Test::More) is not listed in ["SYNOPSIS"](#synopsis).

# BUGS

Please report any bugs or feature requests through the web interface at
[https://github.com/jsf116/Test-Files/issues](https://github.com/jsf116/Test-Files/issues).

# AUTHOR

Phil Crow, <philcrow2000@yahoo.com>

Jurij Fajnberg, <fajnbergj@gmail.com>

# COPYRIGHT AND LICENSE

Copyright 2003-2007 by Phil Crow

Copyright 2020-2024 by Jurij Fajnberg

This module is free software; you can redistribute it and/or modify
it under the same terms as the Perl 5 programming language system itself.
