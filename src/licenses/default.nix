lib:
let
  licenses = builtins.mapAttrs (name: value: value // { inherit name; }) (
    (import ./spdx-licenses.nix lib) // (import ./other-licenses.nix lib)
  );
  licenseExceptions = builtins.mapAttrs (name: value: value // { inherit name; }) (
    (import ./spdx-exceptions.nix lib) // (import ./other-exceptions.nix lib)
  );

  mkLicense =
    {
      # fullName is required
      fullName,
      # shortName and spdxId are optional
      shortName ? null,
      spdxId ? null,
      # licenses are unfree by default
      free ? false,
      # free implies redistributable
      redistributable ? free,
      # no default urls
      urls ? [ ],
    }@attrs:
    lib.types.set "license" (
      attrs
      # set spdx url and make them free and redistributable
      // lib.attrs.when (attrs ? spdxId) {
        urls = [ "https://spdx.org/licenses/${attrs.spdxId}.html" ];
        shortName = attrs.spdxId;
        free = true;
        redistributable = true;
      }
    );

  mkException =
    {
      # fullName is required
      fullName,
      # shortName and spdxId are optional
      shortName ? null,
      spdxId ? null,
      # no default urls
      urls ? [ ],
    }@attrs:
    lib.types.set "exception" (
      attrs
      # set spdx url
      // lib.attrs.when (attrs ? spdxId) {
        urls = [ "https://spdx.org/exceptions/${attrs.spdxId}.html" ];
        shortName = attrs.spdxId;
      }
    );

  mkLicenseWithException =
    license: exception:
    assert lib.types.is "licenses" license;
    assert lib.types.is "exception" exception;
    mkLicense {
      inherit (license) free redistributable;
      fullName = "${license.fullName} WITH ${exception.fullName}";
      urls = license.urls + exception.urls;
    }
    // lib.attrs.when (license.shortName != null && exception.shortName != null) {
      shortName = "${license.shortName} WITH ${exception.shortName}";
    };
in
licenses
// {
  exceptions = licenseExceptions // {
    inherit mkException;
  };
  inherit mkLicense mkLicenseWithException;
}
