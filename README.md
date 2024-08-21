# Wings

My personal helpers that give me wings for development.

## Rails Template

Rails Template to setup a new Rails project with the DevContainer

### Usage

```bash
rails new myapp --css tailwind --asset-pipeline propshaft --database postgresql --devcontainer --template "https://raw.githubusercontent.com/Cosmo/wings/main/starterkit.rb"
```

If you have to deal with a [Zscaler proxy](#zscaler), you can use the following command:

```bash
rails new myapp --css tailwind --asset-pipeline propshaft --database postgresql --devcontainer --template "https://raw.githubusercontent.com/Cosmo/wings/main/starterkit.rb" --zscaler
```

## Zscaler

Add this to your `.zshrc` or `.bashrc`.

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.development

# Export the Zscaler Root CA certificate if it doesn't exist
if [ ! -f ~/.development/Zscaler_Root_CA.crt ]; then
  echo "Exporting Zscaler Root CA certificate..."
  security find-certificate -c "Zscaler Root CA" -p > ~/.development/Zscaler_Root_CA.crt
fi

# Export the Zscaler Root CA certificate to NODE_EXTRA_CA_CERTS
export NODE_EXTRA_CA_CERTS=~/.development/Zscaler_Root_CA.crt
```


