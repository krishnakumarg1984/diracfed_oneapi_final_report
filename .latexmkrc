@generated_exts = "";

push @generated_exts, "glg";

# push @generated_exts, "glg-abr";
# push @generated_exts, "glo";
# push @generated_exts, "glo-abr";
# push @generated_exts, "gls";
# push @generated_exts, "gls-abr";
push @generated_exts, "glstex";
push @generated_exts, "acn";
push @generated_exts, "acr";
push @generated_exts, "alg";
push @generated_exts, "aux";
push @generated_exts, "auxlock";
push @generated_exts, "bbl";
push @generated_exts, "bcf";
push @generated_exts, "blg";
push @generated_exts, "brf";
push @generated_exts, "cb";
push @generated_exts, "cb2";
push @generated_exts, "fdb_latexmk";
push @generated_exts, "fls";
push @generated_exts, "fof";
push @generated_exts, "ist";
push @generated_exts, "loa";
push @generated_exts, "log";
push @generated_exts, "lot";
push @generated_exts, "mtc*";
push @generated_exts, "mypyg";
push @generated_exts, "nav";
push @generated_exts, "nlg";
push @generated_exts, "nlo";
push @generated_exts, "nls";
push @generated_exts, "nmo";
push @generated_exts, "out.ps";
push @generated_exts, "ptc";
push @generated_exts, "run.xml";
push @generated_exts, "slg";
push @generated_exts, "snm";
push @generated_exts, "spl";
push @generated_exts, "syg";
push @generated_exts, "syi";
push @generated_exts, "synctex*";
push @generated_exts, "synctex.gz";
push @generated_exts, "tar.gz";
push @generated_exts, "tdo";
push @generated_exts, "thm";
push @generated_exts, "xdy";
push @generated_exts, "xmpdata";
push @generated_exts, "xmpi";

# $pdflatex='lualatex %O %S -interaction=nonstopmode -halt-on-error --bibtex --recorder';
$pdflatex =
  'pdflatex %O %S -interaction=nonstopmode -halt-on-error --bibtex --recorder';
$pdf_mode        = 1;
$postscript_mode = $dvi_mode = 0;
$clean_ext .=
'%R.bbl  %R_desc.aux %R-figure*.log %R-figure*.dpth %R-figure*.xml %R-figure*.md5 %R-figure*.aux';
$ENV{'TZ'} = 'Europe/London';

@default_files          = ('main.tex');
@default_excluded_files = ( 'preamble/*.tex', 'frontmatter/*.tex' );

# add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep( 'acn', 'acr', 0, 'run_makeglossaries' );

sub run_makeglossaries {
    if ($silent) {
        system "makeglossaries -q $_[0]";
    }
    else {
        system "makeglossaries $_[0]";
    }
}

push @file_not_found, '^Package .* No file `([^\\\']*)\\\'';

$bibtex_use = 1.5;
$compiling_cmd =
  "xdotool search --name \"%D\" set_window --name \"%D compiling\"";
$success_cmd = "xdotool search --name \"%D\" set_window --name \"%D OK\"";
$warning_cmd =
  "xdotool search --name \"%D\" " . "set_window --name \"%D CITE/REF ISSUE\"";
$failure_cmd = "xdotool search --name \"%D\" set_window --name \"%D FAILURE\"";

$cleanup_includes_cusdep_generated = 0;
$cleanup_includes_generated        = 0;

# $fdb_ext="haha";

add_cus_dep( 'aux', 'glstex', 0, 'run_bib2gls' );

sub run_bib2gls {
    my ( $base, $path ) = fileparse( $_[0] );
    my $silent_command = $silent ? "--silent" : "";
    if ($path) {
        my $ret = system("bib2gls $silent_command -d '$path' --group '$base'");
    }
    else {
        my $ret = system("bib2gls $silent_command --group '$_[0]'");
    }

    # Analyze log file.
    local *LOG;
    $LOG = "$_[0].glg";
    if ( !$ret && -e $LOG ) {
        open LOG, "<$LOG";
        while (<LOG>) {
            if (/^Reading (.*\.bib)\s$/) {
                rdb_ensure_file( $rule, $1 );
            }
        }
        close LOG;
    }
    return $ret;
}

# vim: ft=perl
