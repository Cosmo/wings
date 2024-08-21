if ARGV.include?("--zscaler")
  # Set the default path to the Zscaler certificate
  zscaler_default_certificate_path = "~/.development/Zscaler_Root_CA.crt"

  # Check if the file exists
  if File.exist?(File.expand_path(zscaler_default_certificate_path))
    say set_color("Zscaler certificate found at #{zscaler_default_certificate_path}", :green, :on_black)
    zscaler_custom_certificate_path = zscaler_default_certificate_path
  else
    # Ask the user for the path to the Zscaler certificate
    zscaler_custom_certificate_path = ask(set_color("What is the path to the Zscaler certificate? (Press [Return] to use #{zscaler_default_certificate_path} as default path)", :white, :on_black)).presence || ARGV.include?("--zscaler-use-default-path")
  end

  # Add the Zscaler certificate to the project
  copy_file zscaler_custom_certificate_path, "Zscaler_Root_CA.crt"

  # Add commands to the Dockerfile to install the Zscaler certificate
  zscaler_cert = <<-EOF.strip_heredoc

    # Install Zscaler Root CA
    COPY Zscaler_Root_CA.crt /usr/local/share/ca-certificates/

    # Update the CA certificates
    RUN update-ca-certificates

    # Set the NODE_EXTRA_CA_CERTS environment variable to the CA certificates file
    ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
  EOF

  if ARGV.include?("--devcontainer")
    # Add the Zscaler certificate to the Dockerfile
    inject_into_file ".devcontainer/Dockerfile", zscaler_cert, after: /^FROM.*\n/
  end

  append_to_file ".gitignore", ".Zscaler_Root_CA.crt\n"
end

if ARGV.include?("--default-gems") || yes?(set_color("Would you like to add recommended RubyGems? y/n", :white, :on_black))
  # Add the gems to the Gemfile
  gem "redcarpet"
  gem "nokogiri"
  gem "faraday"
  gem "rails_live_reload"
  gem "faker"
  gem "dotenv-rails"
  gem "action_policy"
  gem "solid_queue"
  gem "mission_control-jobs"

  gem_group :development, :test do
    gem "rubocop"
    gem "rspec-rails"
    gem "rubocop-rspec"
    gem "factory_bot_rails"
  end

  gem_group :development do
    # Linting
    gem "erb_lint"
  end

  gem_group :test do
    # Replay HTTP requests
    gem "vcr"

    # Code coverage
    gem "simplecov"
  end
end

if ARGV.include?("--add-vscode-extensions") || yes?(set_color("Would you like to add recommended VSCode extensions to your devcontainer.json? y/n", :white, :on_black))
  recommended_extensions = <<-EOF.strip_heredoc
    "customizations": {
      "vscode": {
        "settings": {
          "extensions.verifySignature": false
        },
        "extensions": [
          "aliariff.vscode-erb-beautify",
          "bradlc.vscode-tailwindcss",
          "connorshea.vscode-ruby-test-adapter",
          "cweijan.vscode-database-client2",
          "dewski.simplecov",
          "elia.erb-formatter",
          "esbenp.prettier-vscode",
          "GitHub.copilot",
          "github.vscode-github-actions",
          "HungVo.htext",
          "KoichiSasada.vscode-rdbg",
          "manuelpuyol.erb-linter",
          "marcoroth.stimulus-lsp",
          "marcoroth.turbo-lsp",
          "ms-vsliveshare.vsliveshare",
          "rubocop.vscode-rubocop",
          "Shopify.ruby-lsp",
          "tavo.rails-schema",
          "usernamehw.errorlens",
          "waderyan.gitblame",
          "wayou.vscode-icons-mac"
        ]
      }
    },
  EOF

  if ARGV.include?("--devcontainer")
    # Replace '// "customizations": {},' with the recommended extensions in the devcontainer.json file
    gsub_file ".devcontainer/devcontainer.json", "// \"customizations\": {},", recommended_extensions
  end
end

if ARGV.include?("--add-vscode-launch") || yes?(set_color("Would you like to add launch.json for debugging and settings.json with linting enabled? y/n", :white, :on_black))
  launch_json = <<-EOF.strip_heredoc
    {
      // Use IntelliSense to learn about possible attributes.
      // Hover to view descriptions of existing attributes.
      // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
      "version": "0.2.0",
      "configurations": [
        {
          "type": "rdbg",
          "name": "Debug current file with rdbg",
          "request": "launch",
          "script": "${file}",
          "args": [],
          "askParameters": true
        },
        {
          "type": "rdbg",
          "name": "Attach with rdbg",
          "request": "attach"
        }
      ]
    }
  EOF

  # Add the launch.json file to the .vscode directory
  create_file ".vscode/launch.json", launch_json

  settings_json = <<-EOF.strip_heredoc
    {
      "[css]": {
        "editor.autoClosingBrackets": "always",
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.insertSpaces": true,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true
      },
      "[erb]": {
        "editor.autoClosingBrackets": "always",
        // Both are off by default:
        // "editor.defaultFormatter": "manuelpuyol.erb-linter", // Warning: This is slow!
        // "editor.defaultFormatter": "elia.erb-formatter", // Warning: This creates weird formatting.
        "editor.defaultFormatter": "aliariff.vscode-erb-beautify", // So far, the best one.
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.insertSpaces": true,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true
      },
      "[javascript]": {
        "editor.autoClosingBrackets": "always",
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.insertSpaces": true,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true
      },
      "[jsonc]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
      },
      "[ruby]": {
        "editor.autoClosingBrackets": "always",
        "editor.defaultFormatter": "Shopify.ruby-lsp",
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.insertSpaces": true,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true
      },
      "[tailwindcss]": {
        "editor.autoClosingBrackets": "always",
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.insertSpaces": true,
        "files.insertFinalNewline": true,
        "files.trimFinalNewlines": true,
        "files.trimTrailingWhitespace": true
      },
      "[yaml]": {
        "diffEditor.ignoreTrimWhitespace": false,
        "editor.autoIndent": "advanced",
        "editor.formatOnSave": true,
        "editor.insertSpaces": true,
        "editor.tabSize": 2
      },
      "editor.cursorSmoothCaretAnimation": "on",
      "editor.fontFamily": "'SF Mono', Menlo, Monaco, 'Courier New', monospace",
      "editor.fontLigatures": true,
      "editor.guides.bracketPairs": true,
      "editor.rulers": [
        120
      ],
      "editor.scrollBeyondLastLine": false,
      "editor.semanticHighlighting.enabled": true,
      "editor.smoothScrolling": true,
      "editor.stickyScroll.enabled": true,
      "editor.tabSize": 2,
      "files.associations": {
        "*.css": "tailwindcss",
        "*.html.erb": "erb"
      },
      "json.format.keepLines": true,
      // "workbench.editor.enablePreview": false,
      "prettier.semi": false,
      "rubyLsp.enabledFeatures": {
        "codeActions": true,
        "codeLens": true,
        "completion": true,
        "definition": true,
        "diagnostics": true,
        "documentHighlights": true,
        "documentLink": true,
        "documentSymbols": true,
        "foldingRanges": true,
        "formatting": true,
        "hover": true,
        "inlayHint": true,
        "onTypeFormatting": true,
        "selectionRanges": true,
        "semanticHighlighting": true,
        "signatureHelp": true,
        "workspaceSymbol": true
      },
      "rubyLsp.enableExperimentalFeatures": true,
      "rubyTestExplorer.testFramework": "rspec",
      "simplecov.coverageOptions": "showUncoveredCodeOnly",
      "simplecov.coverShowCounts": true,
      "vscode-erb-beautify.keepBlankLines": 1,
      "tailwindCSS.experimental.classRegex": [
        "class:\\s*\"([^\"]*)\"",
        "class:\\s*'([^']*)'"
      ],
      "testExplorer.useNativeTesting": true,
      "workbench.editor.tabActionLocation": "left"
    }
  EOF

  # Add the settings.json file to the .vscode directory
  create_file ".vscode/settings.json", settings_json
end

# Add more to .rubocop.yml
rubocop_yml = <<-EOF.strip_heredoc
  require:
    - rubocop-rspec
    - rubocop-rspec_rails
    - rubocop-performance
    - rubocop-erb

  # Your own specialized rules go here
  # Lint/UselessAssignment:
  #   StyleGuide: '#underscore-unused-vars'

  AllCops:
    StyleGuideBaseURL: https://rubystyle.guide
    Include:
      - "app/**/*.rb"
      - "spec/**/*.rb"
      - "Gemfile"
      - "Rakefile"
      - "config.ru"
      # - "app/views/app/**/*.html.erb"

  Style/NumericPredicate:
    EnforcedStyle: predicate
EOF

# Append to the .rubocop.yml file
append_to_file ".rubocop.yml", rubocop_yml

# Initialize Dotenv
create_file ".env", ""
create_file ".env.test", ""
create_file ".env.development", ""
create_file ".env.production", ""
create_file ".env.example", ""

# Add the .env file to the .gitignore
append_to_file ".gitignore", ".env\n"
append_to_file ".gitignore", ".DS_Store\n"

# Initialize Git
git :init
git add: ".", commit: %(-m 'Initial commit')

# Enable UUIDs for the database
# Create a migration to enable the pgcrypto extension
migration_name = "EnablePgcryptoExtension"
migration_file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{migration_name.underscore}.rb"
migration_content = <<-RUBY
  class #{migration_name} < ActiveRecord::Migration[6.0]
    def change
      enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    end
  end
RUBY
create_file "db/migrate/#{migration_file_name}", migration_content

# Create an initializer to set the default primary key type to UUID
initializer "uuid_primary_key.rb", <<-EOF.strip_heredoc
  Rails.application.config.generators do |g|
    g.orm :active_record, primary_key_type: :uuid
  end
EOF

after_bundle do
  # Initialize RSpec
  generate "rspec:install"

  # Initialize SolidQueue
  generate "solid_queue:install"

  # Initialize LiveReload
  generate "rails_live_reload:install"

  # Initialize ActionPolicy
  generate "action_policy:install"

  # Initialize ActiveStorage
  rails_command "active_storage:install"

  # Add solid_queue to the Procfile.dev
  append_to_file "Procfile.dev", "solid_queue: bundle exec rake solid_queue:start\n"
end
