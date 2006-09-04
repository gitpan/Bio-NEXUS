use ExtUtils::MakeMaker;

#if (-e "VERSION") { $version = `cat VERSION`; } else { $version = "1.0";}

WriteMakefile(
    NAME       	       	 => "Bio::NEXUS",
    VERSION_FROM         => 'lib/Bio/NEXUS.pm',
    EXE_FILES            => [ 'exec/nexplot.pl',
   			      'exec/nextool.pl',
   			      'exec/nex2text_tree.pl'
			      ],
    ABSTRACT             => 'Bio::NEXUS - A NEXUS Application Programming Interface in Perl',
    AUTHOR               => 'Hladish, Liang, Qiu, Yang, Gopalan, & Stoltzfus (arlin.stoltzfus@nist.gov)',
   'dist'                => {COMPRESS => 'gzip', SUFFIX => 'gz'},
);
