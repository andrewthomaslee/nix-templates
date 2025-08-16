{
  description = "A Collection of Personal Nix Flake Templates";

  outputs = {self, ...}: {
    defaultTemplate = self.templates.nixfastapi;
    templates = {
      moscripts-x86_64-linux = {
        path = ./templates/moscripts-x86_64-linux;
        description = "Build a python scripts package";
      };
      moscripts = {
        path = ./templates/moscripts;
        description = "Build a python scripts package";
      };
      nixfastapi = {
        path = ./templates/nixfastapi;
        description = "FastAPI managed by Nix and uv2nix";
      };
    };
  };
}
