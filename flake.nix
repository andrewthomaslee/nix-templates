{
  description = "A Collection of Personal Nix Flake Templates";

  outputs = {self, ...}: {
    defaultTemplate = self.templates.moscripts;
    templates = {
      moscripts = {
        path = ./templates/moscripts;
        description = "Build a python scripts package";
      };
    };
  };
}
