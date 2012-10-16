package inc::P9YOSDeps;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub { +{
   %{ super() },
   PREREQ_PM => {},
} };   
 
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
sub os_deps {
   for (lc $^O) {
      if    (/mswin32|cygwin/) {
         return {
            'Win32::Process'       => 0,
            'Win32::Process::Info' => 0,
         };
      }
      elsif ('freebsd') {
         return {'BSD::Process' => 0};
      }
      elsif ('darwin') {
         return {'Proc::ProcessTable' => 0.45};
      }
      elsif ('os2') {
         return {'OS2::Process' => 0};
      }
      elsif ('vms') {
         return {'VMS::Process' => 0};
      }
      elsif ('dos') {
         die "Heh, DOS processes... you're funny!";
      }
      else {
         # let's hope they have /proc
         unless ( -d dir('', 'proc') ) {
            die lc $^O =~ /bsd|dragonfly/ ? 
               "BSD::Process only works for FreeBSD.  Encourage development for $^O, or write your own and I can include it here." :
               "No idea how to handle $^O processes.  Email me with more information!";
         }
      }
   }
   return {};
}
TEMPLATE
 
    return $template;
};
   
__PACKAGE__->meta->make_immutable;

42;
