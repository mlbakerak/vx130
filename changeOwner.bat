docker exec -it --user root  shdw-v20 chown -R 51773:51773 /irisdb /irissys /irisjrn
docker exec -it --user root  irisfdw chown -R 51773:51773 /irisdb /irissys /irisjrn
docker exec -it --user root  vx130 chown -R 51773:51773 /irisdb /irissys /irisjrn
docker exec -it --user root  fdwmirror chown -R 51773:51773 /irisdb /irissys /irisjrn
docker exec -it --user root  vista-anc chown -R 51773:51773 /irisdb /irissys /irisjrn