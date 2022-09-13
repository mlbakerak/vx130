#!/bin/bash
docker cp ancInstall.cls vista-anc:/irisdb/ancInstall.cls
docker exec -it --user root vista-anc chown 51773:51773 /irisdb/ancInstall.cls

docker exec -it vista-anc iris terminal iris -U %SYS
do $SYSTEM.OBJ.Load("/irisdb/ancInstall.cls","ck")
do ##class(manifest.ancInstall).setup()

dismount db rou
http://localhost:52463/csp/sys/op/%25CSP.UI.Portal.DatabaseDetails.zen?$ID1=/irisdb/anc/rou/&DBName=ROU


sudo cp IRIS.DAT anc/db/anc/rou/

mount db rou
http://localhost:52463/csp/sys/op/%25CSP.UI.Portal.DatabaseDetails.zen?$ID1=/irisdb/anc/rou/&DBName=ROU

