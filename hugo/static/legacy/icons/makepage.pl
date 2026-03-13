#!/usr/bin/perl -w
# Program to churn out the web pages for my site.
# In the long term we want to replace the top_html and bottom_html with 
# files to allow dynamic content management. 

# Make stupid cpmment string
$star_string= ("*"x40)."\n";
print $star_string;
print ("Welcome to tng's web content generator\n");
print $star_string;
# Input file will contain text to be put in centre of table. 
print ("What is the input file called?\n");
chomp($input_file=(<STDIN>));

if (-r $input_file){
    print $star_string;
# The file is readable
print ("The input file is readable & called $input_file\n ");
    print $star_string;
} else {
    getoutclause($input_file);
# Oh dear- we can't read from the file
}



#Import the user generated content into the array input_code
open (FILEIN, "$input_file");
# Open the inputfile and import everything into 
@input_code=<FILEIN>;
close (FILEIN);


#Should have got ourselves a decent input file by now
print $star_string;
print ("What is the output file called?\n");
chomp($output_file=(<STDIN>));

if (-w $output_file){
    print ("Warning. File exists. Do you wish to overwrite?");
    chomp($answer=<STDIN>);
    if ($answer =~ /^(y|Y)/){
	print ("OK writing to $output_file");
	write_output($output_file);
    } else {
	print ("O.K. I'm outta here. Choose carefully next time");
	print ("Error");
	exit;    }


 } else {
	write_output($output_file);
}



  


#Print out top section

# Send generic error message about file I/O
sub getoutclause{
    print ("Something went wrong with the input/outputfile $_");
    exit;}


# Subroutine to do the dirty work of outputting the HTML
sub write_output {

$top_html=("
<html>
<head>
<title>Welcome to Montydom- tng's homepage</title>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">
<meta name=\"keywords\" content=\"tim gibbon UNIX linux administrator tim gibbon timothy phd uncle monty international playboy\">
<meta name=\"description\" content=\"Tim Gibbon's homepage hosted at Global Internet\">
</head>

<body bgcolor=\"#EEEEDD\">
<table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"120\" height=\"10\"></td>
    <td bgcolor=\"770011\" colspan=\"4\" align=\"center\"><img src=\"../icons/tngs_header.gif\" width=\"350\" height=\"60\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
    <td colspan=\"4\"><img src=\"../icons/spacer.gif\" width=\"400\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"../index.html\" target=\"_top\"><img src=\"../icons/top.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"Back to the index\"></a></td>
    <td colspan=\"3\" rowspan=\"12\"> 
      <p><img src=\"../icons/spacer.gif\" width=\"50\" height=\"10\"></p>
      <p>&nbsp;</p>
    </td>
    <td rowspan=\"12\" valign=\"top\"> 
");


$bottom_html=("
      </td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"index.html\"><img src=\"../icons/about.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"About tng\"></a></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"../gallery/index.html\"><img src=\"../icons/gallery.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"Mugshots\"></a></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"../links/index.html\"><img src=\"../icons/link.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"My hotlist tagged up\"></a></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"../unix/index.html\"><img src=\"../icons/unix.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"Solaris/OSF1/HP-UX stuff\"></a></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"10\"></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><a href=\"../linux/index.html\"><img src=\"../icons/linux.gif\" width=\"100\" height=\"20\" border=\"0\" alt=\"FSF, GNU, Open source software\"></a></td>
  </tr>
  <tr> 
    <td bgcolor=\"770011\"><img src=\"../icons/spacer.gif\" width=\"10\" height=\"200\"></td>
  </tr>
</table>
</body>
</html>


");





    my $output_file=$_[0];
    	open (OUTPUT_FILE, ">$output_file");
	print (OUTPUT_FILE "$top_html @input_code $bottom_html\n");
	close (OUTPUT_FILE);
}




