# Generate environment variables for each DATA_* service containing the URL.
# 
# Background:

# After an elixir app gets compiled to bytecode, the config files are no
# longer read. The config files contain database connection parameters, among
# other things. The Elixir community has adopted (mostly anyway) a convention
# for telling the module you're configuring to defer to pulling from 
# environment variables instead. This allows the app running in production
# to pull certain configuration parameters, like users and passwords from 
# environment variables instead of forcing the developer to commit them to 
# the repo or force the re-creation of sensitive credentials in the build
# environment.
#
# Problem and Solution:
# 
# The problem here is that ecto (the most popular database mapper) DOESN'T
# support pulling credentials from environment variables *except* when provided
# as a url string. Nanobox doesn't generate DATA_*_URL by default, so we're
# going to iterate through the provided DATA_* evars and generate a
# corresponding _URL evar. Once this is created, an ecto connection can
# be configured like the following example:
# 
# config :core, Core.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   database: "ffsystem",
#   url: {:system, "DATA_DB_URL"}
# 

for component in $(env | grep -o -E 'DATA_.+_HOST' | sed s/_HOST//); do
  # extract USER
  user="${component}_USER"
  
  # extract PASS
  pass="${component}_PASS"
  
  # extract HOST
  host="${component}_HOST"
  
  # export the URL
  export "${component}_URL=${!user}:${!pass}@${!host}"
done
