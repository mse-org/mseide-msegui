{


  Contains the Interbase/Firebird-functions calls
  In this stage only the calls needed for IBConnection are implemented
  Other calls could be simply implemented, using copy-paste from ibase60

  Call InitialiseIbase60 before using any of the calls, and call ReleaseIbase60
  when finished.
}

unit ibase60dyn;

{$DEFINE LinkDynamically}

{$i ibase60.inc}

end.
