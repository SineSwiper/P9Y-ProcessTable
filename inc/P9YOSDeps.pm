package inc::P9YOSDeps;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub { 
   shift->zilla->distmeta->{dynamic_config} = 1;
   +{
      %{ super() },
      # PREREQ_PM => {},
   }
};
 
override _build_WriteMakefile_dump => sub {
   my ($self) = @_;
   my $txt = super();

   $txt =~ s/('PREREQ_PM' =>) \{\}/$1 &os_deps/g;
   return $txt;
};

override _build_MakeFile_PL_template => sub {
    my ($self) = @_;
    my $template = super();
 
    $template .= <<'TEMPLATE';
use v5.10;    

sub os_deps {
   my $prereq = {
      Moo           => 0,
      'Path::Class' => 0,
      'namespace::clean' => 0,
      perl   => 5.10.1,
      sanity => 0,
   };

   for (lc $^O) {
      when (/mswin32|cygwin/) {
         $prereq->{'Win32::Process'}       = 0;
         $prereq->{'Win32::Process::Info'} = 0;
      }
      when ('freebsd') {
         $prereq->{'BSD::Process'} = 0;
      }
      when ('darwin') {
         $prereq->{'Proc::ProcessTable'} = 0.45;
      }
      when ('os2') {
         $prereq->{'OS2::Process'} = 0;
      }
      when ('vms') {
         $prereq->{'VMS::Process'} = 0;
      }
      when ('dos') {
         die "Heh, DOS processes... you're funny!";
      }
      default {
         # let's hope they have /proc
         unless ( -d '/proc' ) {
            die lc $^O =~ /bsd|dragonfly/ ? 
               "BSD::Process only works for FreeBSD.  Encourage development for $^O, or write your own and I can include it here." :
               "No idea how to handle $^O processes.  Email me with more information!";
         }
      }
   }
   return $prereq;
}
TEMPLATE
 
    return $template;
};
   
__PACKAGE__->meta->make_immutable;

42;
