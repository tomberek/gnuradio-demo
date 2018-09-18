self: super:

{
  orc = super.orc.overrideAttrs (old: {
    doCheck = ! super.stdenv.isArm;
  });
}
