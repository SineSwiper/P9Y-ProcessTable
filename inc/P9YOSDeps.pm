package inc::P9YOSDeps;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub {
   shift->zilla->distmeta->{dynamic_config} = 1;
   +{
      %{ super() },
   }
};

override _build_WriteMakefile_dump => sub {
   my ($self) = @_;
   my $txt = super();

   $txt =~ s/('PREREQ_PM' => \{)/$1\n    &os_deps,/g;
   return $txt;
};

override _build_MakeFile_PL_template => sub {
    my ($self) = @_;
    my $template = super();

    $template .= <<'TEMPLATE';
use v5.8.8;

sub os_deps {
    my $_os = lc($^O);

    if ( $_os =~ /mswin32|cygwin/ ) {
      return (
            'Win32::Process'       => 0,
            'Win32::Process::Info' => 0,
            'Path::Class'          => 0.32,  # fixes Cygwin path issue
        );
    }
    elsif ( $_os eq 'freebsd' ) {
      return ( 'BSD::Process' => 0 );
    }
    elsif ( $_os eq 'darwin' ) {
      return ( 'Proc::ProcessTable' => 0.45 );
    }
    elsif ( $_os eq 'os2' ) {
      return ( 'OS2::Process' => 0 );
    }
    elsif ( $_os eq 'vms' ) {
      return ( 'VMS::Process' => 0 );
    }
    elsif ( $_os eq 'dos' ) {
        die "Heh, DOS processes... you're funny!";
    }
    else {
        # let's hope they have /proc
        if ( not -d '/proc' ) {
            if ( $_os =~ /bsd|dragonfly/ ) {
                die "BSD::Process only works for FreeBSD."
                  . " Encourage development for $_os, or write your own and I can include it here.";
            }
            else {
                die "No idea how to handle $_os processes."
                  . " Email me with more information!";
            }
        }
    }
  return ();
}
TEMPLATE

    return $template;
};

__PACKAGE__->meta->make_immutable;

42;
