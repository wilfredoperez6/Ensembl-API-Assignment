use Bio::EnsEMBL::Registry;
#Get arguments passed when script is executed.
my $usrRegion = $ARGV[0];
my $usrStart = $ARGV[1];
my $usrEnd = $ARGV[2];
my $usrStrand = defined($ARGV[3])?$ARGV[3]:'1';
#verify the first three arguments have value
if(!defined($usrRegion) || !defined($usrStart) || !defined($usrEnd))
{
  print "Please specify a region and the start and end of the sequence you wish to convert to GRCh37 version of the chromosome coordinates system.\n";
  exit;
}
#Connect to the EnsEMBL database and retrieve Human registry.
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    -user => 'anonymous',
    -port => 3337
);
#Get chromosome region for GRCh38.
my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
my $chromosome = $slice_adaptor->fetch_by_region( 'chromosome', $usrRegion,$usrStart,$usrEnd,$usrStrand,'GRCh38' );
if(!defined($chromosome))
{
  print "The chromosome region specified  is not defined for the chromosome version GRCh38.";
  exit;
}
#Project to GRCh37.
my @projected_result =  @{$chromosome->project('chromosome','GRCh37')};
if(!@projected_result)
{
  print "The chromosone region specified is not defined for the chromosome version GRCH37 and thus cannot be mapped.";
  exit;
}
#Present result to user.
printf ("The chromosome region %s with segment %s - %s for version GRCH38 can be found in the following segments for version GRCH37:\n",$chromosome->seq_region_name(),$chromosome->start(),$chromosome->end());
foreach my $segment (@projected_result)
{
  my  $new_Slice = $segment->to_Slice();
  if ($chromosome->seq_region_name() =~  $new_Slice->seq_region_name())
  {
    my $seq_region = $new_Slice->seq_region_name();
    my $start      = $new_Slice->start();
    my $end        = $new_Slice->end();
    print "Chromosome region $seq_region with segment $start - $end.\n";
  }
}
print("\n");
