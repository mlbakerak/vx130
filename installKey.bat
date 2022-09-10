
docker cp iris.key shdw-v20:/irissys/mgr/iris.key
docker exec -it --user root  shdw-v20 chown 51773:51773 /irissys/mgr/iris.key

docker cp iris.key irisfdw:/irissys/mgr/iris.key
docker exec -it --user root  irisfdw chown 51773:51773 /irissys/mgr/iris.key

docker cp iris.key vx130:/irissys/mgr/iris.key
docker exec -it --user root  vx130 chown 51773:51773 /irissys/mgr/iris.key

docker cp iris.key fdwmirror:/irissys/mgr/iris.key
docker exec -it --user root  fdwmirror chown 51773:51773 /irissys/mgr/iris.key

docker cp iris.key vista-anc:/irissys/mgr/iris.key
docker exec -it --user root  vista-anc chown 51773:51773 /irissys/mgr/iris.key

