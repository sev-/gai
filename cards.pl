#!/usr/local/bin/perl

# $Id:$
#
# Author	  : Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Created On	  : Mon Jun 10 12:20:10 UKD 1997 sev
# Last Modified By: Eugene Sandulenko <sev@rd.zgik.zaporizhzhe.ua>
# Last Modified On: 
# Status	  : Beta version.

do "config.ph";

$image = $www_prefix.'dot.gif';

&getFormData;

$card = $FORM{card} || 1;
$question = $FORM{question} || 1;
$mode = $FORM{mode} || 1;

$cardquestion = 0;
@cardanswers = ();

print "Content-type: text/html\npragma: no-cache\n\n";

open (CARDS, $texts_file) || (print "Can not open file $texts_file ($!)\n", exit 0);

@request_result = ();

if ($question > $NUMQUESTS) {
  print "Error: Bad question number. Must be 10 or less. ($question)\n";
  exit 0;
}

LOOP1:
while(<CARDS>) {
  if (/^-\s$card\s-+/) {
    while (<CARDS>) {
      if (/^$question\).*/) {
        chop;
        $cardquestion = $_;
        while (($a = <CARDS>) !~ /^$/) {
          chop $a;
          $a =~ s/^[0-9]+\. //;
          push(@cardanswers, $a);
        }
        last LOOP1;
      }
    }
  }
}

unless ($cardquestion) {
  print "Error: Can't find card number '$card' in file '$texts_file'\n";
  print "<br>Parameters are:<br>\n";
  for $key (keys(%FORM)) {
    print "'$key' = '$FORM{$key}'<br>\n";
  }
  exit 0;
}

if(-r $absolute_prefix.$card."-".$question.".gif") {
  $image = $www_prefix.$card."-".$question.".gif";

# get image size
  open (GIF, $absolute_prefix.$card."-".$question.".gif");
  seek (GIF, 6, 0);
  read (GIF, $size, 4);
  ($image_width, $image_height) = unpack ("s2", $size);
  close (GIF);
}
		
$numans = $#cardanswers+1;
$tablewidth = 500;
$fontsize = 3;

if ($mode == 2) {
  $tablewidth = 190;
  $image_width = int($image_width/3);
  $image_height = int($image_height/3);
  $fontsize = -5;
}
		
push(@request_result, <<EODATA);
<html>
<title>Билет $card вопрос $question</title>
<body $bodyline>

<center>
$FORM{name}<br>

<form method="get" action="/gai-bin/check.pl">

<table width=$tablewidth border=0 cellspacing=1 cellpadding=1>
<tr><td colspan=3><font size=$fontsize> $cardquestion</font>

<tr><td rowspan=$numans valign=center align=center><img src="$image" width=$image_width height=$image_height>
EODATA

$i = 1;
for $question (@cardanswers) {
  if ($mode == 1) {
    push(@request_result, (($i == 1)?"    ":"<tr>", "<td valign=top align=right><input type=radio name=responce value=$i>\n    <td valign=top align=left><font size=$fontsize> $question</font>\n"));
  } elsif ($mode == 2) {
    push(@request_result, (($i == 1)?"    ":"<tr>", "<td>\n    <td valign=top align=left><font size=$fontsize> $question</font>\n"));
  }
  $i++;
}

push(@request_result, <<EOMIDDLE) if($mode == 1);
<tr><td colspan=2 align=center><input type=submit value=" Готово ">
    <td align=center><input type=submit value="Пропустить" name=pass>
<input type=hidden name=card value=$card>
<input type=hidden name=name value="$FORM{name}">
<input type=hidden name=question value=$question>
<input type=hidden name=starttime value=$FORM{starttime}>
EOMIDDLE

push(@request_result, <<EOTAIL);
</table>

</form>
</center>
</font>
</body>
</html>
EOTAIL

&print_HTML;

exit 0;
