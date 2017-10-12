use strict;
use URI;
use Web::Scraper;
use WWW::Mechanize;
use Encode;
use Data::Dumper;

#21294262
#22276919

# my $pid = "22276919";
# my @links = get_pdf_links($pid);
# print join("\n",@links)."\n";
#
# my $PDFLink = getPDFLink($links[0]);
#
# print $PDFLink."\n";
#
# downloadPDF($PDFLink, "pdf/".$pid.".pdf");

#this is an issue link
#my $PDFLink = getPDFLink("http://onlinelibrary.wiley.com/doi/10.1002/smll.201001619/abstract");

my $PDFLink = getPDFLink("https://jnanobiotechnology.biomedcentral.com/articles/10.1186/1477-3155-10-5");

print $PDFLink."\n";
#downloadPDF($PDFLink, "pdf/test.pdf");
#input: pubmed id of article
#output: array containing links to full page source of article
sub get_pdf_links(){
    my ($pid) = shift;
    my $link_scraper = scraper{
      process ".icons > a", 'links[]' => scraper{
        process 'a', url => '@href';
      };
    };
    my $result = $link_scraper->scrape( URI->new("https://www.ncbi.nlm.nih.gov/pubmed/".$pid) );
    die "No full-paper links were found with PMID: ".$pid if not exists $result->{links};
    my @links = ();

    for my $link (@{$result->{links}}){
      push @links, $link->{url};
    }
    return @links;

}

#input: url of webpage containing the full text of an article pdf
#output: link to pdf
sub getPDFLink(){
  my $fullTextURL = shift;
  my $mech = WWW::Mechanize->new();
  $mech->get($fullTextURL);

  ##if contains word download, go there.
  my $link;
  if($mech->find_link(text_regex => qr/download/i)){
    $link = $mech->find_link(text_regex => qr/download/i);
  }



  # print $mech->uri()."\n";
  # $mech->follow_link( text_regex => qr/pdf/i );
  # print $mech->uri()."\n";
  # $mech->follow_link( text_regex => qr//i );
  # print $mech->uri()."\n";
  # while(not substr($mech->uri(), -3) eq 'pdf'){
  #   print $mech->uri()."\n";
  #   $mech->follow_link( text_regex => qr/pdf|download/i );
  # }


  ### this section will require a ton of hardcoding based on website, we must select the correct link but some pages contain multiple pdf files ###


#  die "Unable to find PDF on page: ".$fullTextURL if not $link;



  my $linkURL = $link->url_abs();
#  $mech->follow_link( url => $link );

}

#input: url of pdf, location to save
#output: pdf
sub downloadPDF(){
  my $pdfURL = shift;
  my $location = shift;
  my $mech = WWW::Mechanize->new();
  my $filename = $pdfURL;
  $filename =~ s[^.+/][];
#  $mech->get( $pdfURL, ':content_file' => $filename );
  $mech->get($pdfURL);
  $mech->save_content($location);

  #print "   ", -s $filename, " bytes\n";

}
