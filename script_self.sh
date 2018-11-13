RKDIR=/home/ubuntu/self_healing/

restart() {
        case $host in
                api-brf.dialog.cm)
                        container=dial-api-brf-prod;;
                api-gip.dialog.cm)
                        container=dial-api-gip-prod;;
                api-hsp.dialog.cm)
                        container=dial-api-hsp-prod;;
                api-impar.dialog.cm)
                        container=dial-api-impar-prod;;
                api-klabin.dialog.cm)
                        container=dial-api-klabin-prod;;
                api-light.dialog.cm)
                        container=dial-api-light-prod;;
                api-multi.dialog.cm)
                        container=dial-api-multi-prod;;
                api-pepapp.dialog.cm)
                        container=dial-api-pep-prod;;
                api-pnl.dialog.cm)
                        container=dial-api-pn-prod;;
                api-record.dialog.cm)
                        container=dial-api-rec-prod;;
                api-somlivre.dialog.cm)
                        container=dial-api-sl-prod;;
                api-zs.dialog.cm)
                        container=dial-api-zs-prod;;
                *)
                        unset container
                        return 0;;
        esac

        dokku logs $container >> $WORKDIR/self_healing.log
        dokku ps:restart $container >> $WORKDIR/self_healing.log 2&>1 && \
                echo "[$DATE] $container restarted sucessfully" >> $WORKDIR/self_healing.log || \
                echo "[$DATE] $container error restarting" >> $WORKDIR/self_healing.log
        sleep 20
        sudo docker ps | egrep -e '\.15[0-9]+' | awk '{ print $1 }' | xargs -n 1 sudo docker kill >> $WORKDIR/self_healing.log 2> /dev/null
}

for host in $(cat $WORKDIR/hosts.txt)
do
        response=$(curl -s --header "Host: $host" "http://localhost:8080/health-check/")

        if [ ! "$response" = "OK" ]; then
                if [ -f $WORKDIR/stop ]; then
                        echo "[$DATE] $host is not working, but stop file present" >> $WORKDIR/self_healing.log
                else
                        echo "[$DATE] $host is not working, restarting." >> $WORKDIR/self_healing.log
		curl -X POST -H "Content-Type: application/json" -d '{ "text": "[AWS]-[us-east-1c]-[EC2]-appHost1-prod", "attachments": [ { "fallback": �~@~\Container restarted", "author_name": "Sender: Blue Digital Container Monitor", "title": "Container ${host} was been restarted", "text": "Health-check not responding", } ] }' https://hooks.slack.com/services/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

                        restart
                fi
        fi

done


