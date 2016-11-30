# ${1:Project Name}

TODO: Write a project description

## Installation

TODO: Describe the installation process

## Usage
skippy.py <RUNDIRECTORY>

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

v0.1: Initial design

## Credits

TODO: Write credits

## License

TODO: Write license


# specification/requirements
## parse QC data
parse all metrics file in directory (picard2json)
- use Crimson
- custom parser for failing files (picard2json)
extract runlogs (sqlite2json)
- own function
Extract BCL2FASTQ stats
- From BaseSpace?
- XML2JSON
Add Flagstat
- crimson
## aggregate data and store (aggregatejson,json2mongo)
- loader by directory
##
archive run (archiveRun)
cleanup (cleanupRun)
## query engine
Simple webpage?
