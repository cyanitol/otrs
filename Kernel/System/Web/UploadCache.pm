# --
# Kernel/System/Web/UploadCache.pm - a fs upload cache
# Copyright (C) 2001-2007 OTRS GmbH, http://otrs.org/
# --
# $Id: UploadCache.pm,v 1.3.2.1 2007-03-12 23:56:52 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::System::Web::UploadCache;

use strict;

use vars qw($VERSION);

$VERSION = '$Revision: 1.3.2.1 $ ';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

=head1 NAME

Kernel::System::Web::UploadCache - a upload file system cache

=head1 SYNOPSIS

All upload cache functions.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create param object

  use Kernel::Config;
  use Kernel::System::Log;
  use Kernel::System::DB;
  use Kernel::System::Web::UploadCache;

  my $ConfigObject = Kernel::Config->new();
  my $LogObject    = Kernel::System::Log->new(
      ConfigObject => $ConfigObject,
  );
  my $DBObject = Kernel::System::DB->new(
      ConfigObject => $ConfigObject,
      LogObject => $LogObject,
  );
  my $UploadParamObject = Kernel::System::Web::UploadCache->new(
      ConfigObject => $ConfigObject,
      LogObject => $LogObject,
      DBObject => $DBObject,
  );

=cut

sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless ($Self, $Type);
    # check needed objects
    foreach (qw(ConfigObject LogObject EncodeObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    # load generator auth module
    $Self->{GenericModule} = $Self->{ConfigObject}->Get('WebUploadCacheModule')
      || 'Kernel::System::Web::UploadCache::DB';
    if (!eval "require $Self->{GenericModule}") {
        die "Can't load backend module $Self->{GenericModule}! $@";
    }

    $Self->{Backend} = $Self->{GenericModule}->new(%Param);

    return $Self;
}

=item FormIDCreate()

create a new form id

  my $FormID = $UploadParamObject->FormIDCreate();

=cut

sub FormIDCreate {
    my $Self = shift;
    return $Self->{Backend}->FormIDCreate(@_);
}

=item FormIDRemove()

remove all data with form id

  $UploadParamObject->FormIDRemove(FormID => 123456);

=cut

sub FormIDRemove {
    my $Self = shift;
    return $Self->{Backend}->FormIDRemove(@_);
}

=item FormIDAddFile()

add a file to the form id

  $UploadParamObject->FormIDAddFile(
      FormID => 12345,
      Filename => 'somefile.html',
      Content => $FileInSting,
      ContentType => 'text/html',
  );

=cut

sub FormIDAddFile {
    my $Self = shift;
    return $Self->{Backend}->FormIDAddFile(@_);
}

=item FormIDRemoveFile()

removes a file to the form id

  $UploadParamObject->FormIDRemoveFile(
      FormID => 12345,
      FileID => 1,
  );

=cut

sub FormIDRemoveFile {
    my $Self = shift;
    return $Self->{Backend}->FormIDRemoveFile(@_);
}

=item FormIDGetAllFilesData()

returns a array with hash ref of all form id files

  my @Data = $UploadParamObject->FormIDGetAllFilesData(
      FormID => 12345,
  );

  Return data of on hash is Content, ContentType, Filename, Filesize, FileID;

=cut

sub FormIDGetAllFilesData {
    my $Self = shift;
    return @{$Self->{Backend}->FormIDGetAllFilesData(@_)};
}

=item FormIDGetAllFilesMeta()

returns a array with hash ref of all form id files

Note: No Content will be returned, just meta data.

  my @Data = $UploadParamObject->FormIDGetAllFilesMeta(
      FormID => 12345,
  );

  Return data of on hash is Filename, Filesize, FileID;

=cut

sub FormIDGetAllFilesMeta {
    my $Self = shift;
    return @{$Self->{Backend}->FormIDGetAllFilesMeta(@_)};
}

=item FormIDCleanUp()

Removed no longer needed tmp file.

Each file older then 1 day will be removed.

  $UploadParamObject->FormIDCleanUp();

=cut

sub FormIDCleanUp {
    my $Self = shift;
    return $Self->{Backend}->FormIDCleanUp(@_);
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see http://www.gnu.org/licenses/gpl.txt.

=cut

=head1 VERSION

$Revision: 1.3.2.1 $ $Date: 2007-03-12 23:56:52 $

=cut
