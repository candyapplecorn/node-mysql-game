# Create json credentials file
cat <<EOT >credentials.json
{
    "database" : "html5game",
    "username" : "html5game",
    "password" : "developersguild"
}
EOT

if [[ $# == 1 && $1 == "--install" || $1 == "-i" ]]; then
# Install dependencies
dependencies=(bluebird express socket.io mysql sequelize cookie-parser express-session express-sequelize-session mime)
for dep in ${dependencies[@]};
do
    npm install --save $dep;
done;
fi;
