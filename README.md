compareGemSettings
==================

This application is used to compare gem_settings files for GEM/3.3.8.  In order to do this,
all the namelists and their respective variable declarations were copied into the source
of this file.  Every variable is referenced back to its original source, but this will be
discussed later in the expansion center.

The Fortran component of this app declares all the variables and sets their default values
as the GEM model would set them.  It then reads in the specified namelist file to set these
variables.  Once set, it prints out all the variables.

This output it captured by the python component of this app which formats the variables into a
CSV file and carries out some other cleaning tasks (e.g. removing repeated lines.)

The motivation of this is that many settings files for GEM rely on default values, define values
in different orders, have varying custom whitespace, and can be subtlety different making it
difficult to spot differences.  This app organizes all the key/value pairs into a consistent,
ordered, and exportable format that allows for easy comparison.

For example, the CSV output can be imported into a spreadsheet where multiple settings files
can be compared at once.

Limitations
===========

This app is only written for GEM/3.3.8, and does not compare chemistry configuration keys.

Expansion
=========

If this app is well adopted, it can be expanded to work with multiple versions of GEM. My
recommendation for this would be:

- Include GEM cdk files for variable declarations rather than manually copying them into
  the source
- Perform a similar task for namelist declarations

This was not done in this version in the interest of de-coupling this app from the EC
environment for quick development.
