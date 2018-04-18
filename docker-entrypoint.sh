#!/bin/sh

# Check that the MySQL host is available
if [ -n "$MYSQL_HOSTNAME" ]; then
	echo "Waiting for $MYSQL_HOSTNAME to be ready"
	while ! mysqladmin ping -h $MYSQL_HOSTNAME --silent; do
		# Show some progress
		echo -n '.'
		sleep 1
	done
	echo "$MYSQL_HOSTNAME is ready"
	# Give it another second
	sleep 1
fi

# Start Vapor app
echo "Starting release build of Vapor app in production mode"
exec /vapor/.build/release/Run --env production
