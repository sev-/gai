$names_file = '/usr/local/www/data/gai/names.lst';
$manager_script = '/gai-bin/manager.pl';
$bodyline = 'bgcolor=#ffffff';

$exams_file = '/usr/local/www/data/gai/on_exams.lst';
$pick_script = '/gai-bin/pickname.pl';

$NUMCARDS = 30;
$NUMQUESTS = 10;

$MAXTIME = 20*60; # exams time in seconds

$texts_file = '/usr/local/www/data/gai/texts.lst';
$absolute_prefix = '/usr/local/www/data/gai/cards/';
$www_prefix = '/gai/cards/';

$responces_file = '/usr/local/www/data/gai/responces.lst';



############################################################################

sub getFormData {
    $buffer = "";

    if ($ENV{'REQUEST_METHOD'} eq 'GET') {
        $buffer = $ENV{'QUERY_STRING'};
    }
    else {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }

    foreach (split(/&/, $buffer)) {
        ($key, $value) = split(/=/, $_);
        $key   = &decodeURL($key);
        $key =~ tr/р- └-▀/ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЪюабцдефгхийклмнопярстужвьызшэщчъ/;
	$FORM_{$key} = $value;
        $value = &decodeURL($value);
        $value =~ tr/р- └-▀/ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЪюабцдефгхийклмнопярстужвьызшэщчъ/;
        $FORM{$key} = $value;
    }
}

sub decodeURL {
    $_ = shift;
    tr/+/ /;
    s/%(..)/pack('c', hex($1))/eg;
    return($_);
}

sub print_HTML {
  foreach $line (@request_result) {
# alt2koi
  $line =~ tr/ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЪюабцдефгхийклмнопярстужвьызшэщчъ/р- └-▀/;
# alt2win
#  $line =~ tr/АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмноп░▒▓│┤╡╢╖╕╣║╗╝╜╛┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀рстуфхцчшщъыьэюяЁёЄєЇїЎў°∙·√№¤■ /└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀рстуфхцчшщъыьэюя░▒▓▓│╡╕╣║║╗╝╜╛┐┐└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀ЁёЄєЇїЎў°∙·√№¤■ ЁёЄєЇїЎў°∙·√№¤■ /;
    print $line;
  }
}

sub read_onexams {
  open (ONEXAMS, "$exams_file") || return 0;
#   (print "Content-type: text/html\n\nCan not open file $exams_file ($!)\n", exit 0);

  @onexams_chosen_card = %onexams_card= %onexams_replies = %onexams_faults = ();

  while (<ONEXAMS>) {
    next if(/^\s*$/);
    chop;
    @a = split (/\|/, $_);
    $onexams_chosen_card[$a[1]] = 1 if ($a[3] < 2); # only when haven't passed
    $onexams_card{$a[0]} = $a[1];
    $onexams_replies{$a[0]} = $a[2];
    $onexams_faults{$a[0]} = $a[3];
    $onexams_starttime{$a[0]} = $a[4];
  }
  close ONEXAMS;
  return 1;
}

sub write_onexams {
  open (ONEXAMS, ">$exams_file") ||
   (print "Content-type: text/html\n\nCan not open file $exams_file ($!)\n", exit 0);

  for $people (keys %onexams_card) {
    print ONEXAMS "$people|$onexams_card{$people}|$onexams_replies{$people}|$onexams_faults{$people}|$onexams_starttime{$people}\n";
  }
  close ONEXAMS;
}

sub read_names {
  open (NAMES, $names_file) || 
    (print "Content-type: text/html\n\nCan not open file $names_file ($!)\n", exit 0);
  %names = ();
  while (<NAMES>) {
    next if (/^\s*$/);
    chop;
    $names{$_} = '1';
  }
  close NAMES;
}

sub write_names {
  open (NAMES, ">$names_file") || 
    (print "Content-type: text/html\n\nCan not open file $names_file ($!)\n", exit 0);
  for $key (keys %names) {
    print NAMES "$key\n" if($names{$key} == 1);
  }
  close NAMES;
}
