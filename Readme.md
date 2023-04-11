# Unit tested Bash project template with Pre-commit

[![Travis Build Status](https://img.shields.io/travis/a-t-0/shell_unit_testing_template.svg)](https://travis-ci.org/a-t-0/shell_unit_testing_template)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

You can use this as a starting point for your Bash/shell project with:

- Unit testing
- Code Coverage (100 %)
- Pre-commit:
  - shfmt (Auto-formatter)
  - Shellcheck
- Continuous Integration (GitLab CI)

That way, you start your project in a clean, tested environment.

## Usage

4 sets of commands are given, pre-requisites, uninstallation, installation, and
step-by-step commands with commented explanations.

### Prerequisites

```sh

sudo apt install git -y
sudo apt install pip -y
pip install dash
pip install pandas
git clone https://github.com/HiveMinds/SSL4Tor.git
cd SSL4Tor
python3 src/website/mwe_dash.py --port 8050 --use-https
```

Then open a new termina.

### Delete Pre-existing Data

```bash
./src/main.sh --project-name gitlab \
  --delete-onion-domain \
  --delete-ssl-certs
```

### Single command

```bash
./src/main.sh --make-onion-domain \
  --project-name gitlab \
  --local-project-port 8050 \
  --public-port-to-access-onion 443 \
  --make-ssl-certs \
  --ssl-password somepassword \
  --add-ssl-root-cert-to-apt-firefox
```

### Step-by-step

```bash
# Remove tor and accompanying files.
./src/main.sh -do -n gitlab

# Install tor and create onion domain for the gitlab service
# To access a local project running on port localhost:8050 via: <code>.onion:90
./src/main.sh -mo -n gitlab -lpp 8050 -ppo 90
# To access a local project running on localhost:8050 via: <code>.onion:443
./src/main.sh -mo -n gitlab -lpp 8050 -ppo 443
./src/main.sh -fta # Convert snap Firefox to apt firefox.
./src/main.sh -asf -n gitlab # add root CA cert to APT firefox.
./src/main.sh -ms -n gitlab -sp somepassword # Make ssl cert
```

## Testing

Put your unit test files (with extension .bats) in folder: `/test/`

```bash
pip install dash
pip install pandas
```

### Developer Requirements

(Re)-install the required submodules with:

```sh
chmod +x install-bats-libs.sh
./install-bats-libs.sh
```

Install:

```sh
sudo gem install bats
sudo gem install bashcov
sudo apt install shfmt -y
pre-commit install
pre-commit autoupdate
```

### Pre-commit

Run pre-commit with:

```sh
pre-commit run --all
```

### Tests

Run the tests with:

```sh
bats test
```

If you want to run particular tests, you could use the `test.sh` file:

```sh
chmod +x test.sh
./test.sh
```

### Code coverage

```sh
bashcov bats test
```

## How to help

- Include bash code coverage in GitLab CI.
- Add [additional](https://pre-commit.com/hooks.html) (relevant) pre-commit hooks.
- Develop Bash documentation checks
  [here](https://github.com/TruCol/checkstyle-for-bash), and add them to this
  pre-commit.
