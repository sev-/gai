#!/usr/local/bin/perl

print "Content-type: text/html\npragma: no-cache\n\n";

&getFormData;

$card=$FORM{'card'};

print <<EOHTML;
<html>
<title>Card number $card</title>
<frameset rows="150,150,150" border=0 frameborder=0 framespacing=0 framepadding=0>
  <frameset cols="150,150,150,150" border=0 frameborder=0 framespacing=0 framepadding=0>
    <frame target="2" name="1" src="/gai-bin/cards.pl?card=$card&question=1&mode=2" border=0 noresize>
    <frame target="3" name="2" src="/gai-bin/cards.pl?card=$card&question=2&mode=2" border=0 noresize scrollbars=no>
    <frame target="4" name="3" src="/gai-bin/cards.pl?card=$card&question=3&mode=2" border=0 noresize>
    <frame target="5" name="4" src="/gai-bin/cards.pl?card=$card&question=4&mode=2" border=0 noresize>
  </frameset>
  <frameset cols="150,150,150,150" border=0 frameborder=0 framespacing=0 framepadding=0>
    <frame target="6" name="5" src="/gai-bin/cards.pl?card=$card&question=5&mode=2" border=0 noresize>
    <frame target="7" name="6" src="/gai-bin/cards.pl?card=$card&question=6&mode=2" border=0 noresize>
    <frame target="8" name="7" src="/gai-bin/cards.pl?card=$card&question=7&mode=2" border=0 noresize>
    <frame target="9" name="8" src="/gai-bin/cards.pl?card=$card&question=8&mode=2" border=0 noresize>
  </frameset>
  <frameset cols="150,150,150,150" border=0 frameborder=0 framespacing=0 framepadding=0>
    <frame target="10" name="9" src="empty.html" bordrer=0 noresize>
    <frame target="11" name="10" src="/gai-bin/cards.pl?card=$card&question=9&mode=2" border=0 noresize>
    <frame target="12" name="11" src="/gai-bin/cards.pl?card=$card&question=10&mode=2" border=0 noresize ruler=0
    <frame             name="12" src="empty.html" bordrer=0 noresize>
  </frameset>
</frameset>
</html>
EOHTML

exit 0;

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
#        $key =~ tr/р- └-▀/ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЪюабцдефгхийклмнопярстужвьызшэщчъ/;
        $value = &decodeURL($value);
#        $value =~ tr/р- └-▀/ЮАБЦДЕФГХИЙКЛМНОПЯРСТУЖВЬЫЗШЭЩЧЪюабцдефгхийклмнопярстужвьызшэщчъ/;
        $FORM{$key} = $value;
    }
}

sub decodeURL {
    $_ = shift;
    tr/+/ /;
    s/%(..)/pack('c', hex($1))/eg;
    return($_);
}

