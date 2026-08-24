# Migración de cron + AWX CLI a Schedules de Ansible Tower

## Objetivo

Eliminar del flujo operativo:

- `crontab` del servidor RHEL.
- `run_awx_all.sh`.
- `awx_prompt.sh`.

No se modifica:

- El Job Template base `Elastic_TESTING`.
- El playbook actual.
- El role `tower_orchestator`.
- La lógica interna que genera inventarios/templates ad-hoc.

El scheduling pasa a ser responsabilidad exclusiva de Ansible Tower.

## Funcionamiento anterior

```text
crontab RHEL
    |
    v
run_awx_all.sh
    |
    +-- lunes     -> weblogic.list
    +-- martes    -> websphere.list
    +-- miércoles -> jbosseap.list
    +-- jueves    -> tomcat.list
    +-- viernes   -> apache.list
    +-- sábado    -> iis.list
    +-- domingo   -> sin ejecución
    |
    v
awx_prompt.sh
    |
    v
Elastic_TESTING
    |
    v
role actual
```

`run_awx_all.sh` recorría cada fichero línea por línea y esperaba 60 segundos entre lanzamientos.

Cada línea tenía este formato:

```text
REGION|ENV|PRODUCT|LIMIT|INSTANCE_GROUP|LOCATION_ZONE
```

Ejemplo:

```text
EMEA|DEV|jbosseap|jbosseap_emea_dev_core|none|CORE
```

## Funcionamiento nuevo

```text
Ansible Tower
|
+-- Schedule 1 ----> Elastic_TESTING
+-- Schedule 2 ----> Elastic_TESTING
+-- Schedule 3 ----> Elastic_TESTING
+-- ...
                     |
                     v
                  role actual
```

Cada antigua línea de los `.list` se convierte en **un Schedule independiente de `Elastic_TESTING`**.

No existe ningún script intermedio durante la ejecución.

## Calendario

| Día | Producto/fichero anterior | Schedules |
|---|---|---:|
| Lunes | `weblogic.list` | 7 |
| Martes | `websphere.list` | 30 |
| Miércoles | `jbosseap.list` | 12 |
| Jueves | `tomcat.list` | 35 |
| Viernes | `apache.list` | 71 |
| Sábado | `iis.list` | 6 |
| Domingo | Sin ejecución | 0 |
| **Total** | | **161** |

La hora inicial debe ser la misma que utilizaba el cron anterior.

Para conservar el `sleep 60` existente, los schedules del mismo día se programan con un minuto de separación:

```text
HH:00  ejecución 01
HH:01  ejecución 02
HH:02  ejecución 03
...
```

## Conversión de una línea a Extra Variables

Entrada anterior:

```text
EMEA|DEV|jbosseap|jbosseap_emea_dev_core|none|CORE
```

Schedule de `Elastic_TESTING`:

```yaml
region: EMEA
envs: DEV
product: jbosseap
limit: jbosseap_emea_dev_core
update: update
instance_group: MiddlewareFR
data_env: prod
is_ETS: "false"
location_zone: CORE
```

Reglas heredadas de los scripts:

- `update` siempre es `update`.
- `data_env` siempre es `prod`.
- `INSTANCE_GROUP=none` se convierte en `MiddlewareFR`.
- `INSTANCE_GROUP=iv2amer` se mantiene como `iv2amer`.
- `INSTANCE_GROUP=iv2apac` se mantiene como `iv2apac`.
- Si `LOCATION_ZONE=ETS`, `is_ETS="true"`.
- Para cualquier otra zona, `is_ETS="false"`.
- `location_zone` conserva `CORE`, `DMZI`, `MZR`, `ETS`, etc.

## Configuración en Tower

Ruta:

```text
Templates
  -> Elastic_TESTING
     -> Schedules
```

Para cada entrada se crea un Schedule con:

1. Recurrencia `Weekly`.
2. Día correspondiente al producto.
3. Hora correspondiente a su posición en la secuencia.
4. `Extra Variables` equivalentes a la antigua llamada de `awx_prompt.sh`.

`Elastic_TESTING` debe permitir las variables utilizadas por los schedules mediante la configuración actual de Prompt on Launch / Survey correspondiente.

## Convención de nombres

Convención propuesta:

```text
<PRODUCT>_<REGION>_<ENV>_<LOCATION_ZONE>
```

Ejemplos:

```text
jbosseap_EMEA_DEV_CORE
jbosseap_AMER_PRD_CORE
apache_EMEA_PRD_ETS
tomcat_ibm_AMER_DEV_MZR
```

Si una combinación pudiera repetirse, utilizar el valor de `limit` como nombre del Schedule evita colisiones:

```text
jbosseap_emea_dev_core
apache_dmzi_emea_dev_dmzi
sso_as_a_service_ibm_dmzr_emea_dev_mzr
```

Usar directamente el `limit` es la opción más simple y trazable.

# Definición de Schedules

Las tablas siguientes contienen los valores procedentes de los antiguos `.list`.

Las columnas `update=update` y `data_env=prod` son comunes a todos y no se repiten en las tablas.

`IG` muestra ya el valor final que debe recibir `Elastic_TESTING`: `none` se ha sustituido por `MiddlewareFR`.

## Lunes - WebLogic

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `weblogic` | `weblogic_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 2 | EMEA | STG | `weblogic` | `weblogic_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 3 | EMEA | PRD | `weblogic` | `weblogic_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 4 | APAC | DEV | `weblogic` | `weblogic_apac_dev_core` | `iv2apac` | CORE | false |
| 5 | APAC | STG | `weblogic` | `weblogic_apac_stg_core` | `iv2apac` | CORE | false |
| 6 | AMER | DEV | `weblogic` | `weblogic_amer_dev_core` | `iv2amer` | CORE | false |
| 7 | AMER | PRD | `weblogic` | `weblogic_amer_prd_core` | `iv2amer` | CORE | false |

## Martes - WebSphere

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `websphere_base` | `websphere_base_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 2 | EMEA | STG | `websphere_base` | `websphere_base_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 3 | EMEA | PRD | `websphere_base` | `websphere_base_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 4 | APAC | DEV | `websphere_base` | `websphere_base_apac_dev_core` | `iv2apac` | CORE | false |
| 5 | APAC | STG | `websphere_base` | `websphere_base_apac_stg_core` | `iv2apac` | CORE | false |
| 6 | EMEA | DEV | `wasbase_admin_vmware` | `wasbase_admin_vmware_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 7 | EMEA | STG | `wasbase_admin_vmware` | `wasbase_admin_vmware_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 8 | EMEA | PRD | `wasbase_admin_vmware` | `wasbase_admin_vmware_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 9 | APAC | DEV | `wasbase_admin_vmware` | `wasbase_admin_vmware_apac_dev_core` | `iv2apac` | CORE | false |
| 10 | APAC | STG | `wasbase_admin_vmware` | `wasbase_admin_vmware_apac_stg_core` | `iv2apac` | CORE | false |
| 11 | APAC | PRD | `wasbase_admin_vmware` | `wasbase_admin_vmware_apac_prd_core` | `iv2apac` | CORE | false |
| 12 | AMER | DEV | `wasbase_admin_vmware` | `wasbase_admin_vmware_amer_dev_core` | `iv2amer` | CORE | false |
| 13 | AMER | STG | `wasbase_admin_vmware` | `wasbase_admin_vmware_amer_stg_core` | `iv2amer` | CORE | false |
| 14 | AMER | PRD | `wasbase_admin_vmware` | `wasbase_admin_vmware_amer_prd_core` | `iv2amer` | CORE | false |
| 15 | EMEA | DEV | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 16 | EMEA | STG | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 17 | EMEA | PRD | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 18 | APAC | DEV | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_apac_dev_core` | `iv2apac` | CORE | false |
| 19 | APAC | STG | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_apac_stg_core` | `iv2apac` | CORE | false |
| 20 | APAC | PRD | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_apac_prd_core` | `iv2apac` | CORE | false |
| 21 | AMER | DEV | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_amer_dev_core` | `iv2amer` | CORE | false |
| 22 | AMER | STG | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_amer_stg_core` | `iv2amer` | CORE | false |
| 23 | AMER | PRD | `dpi_upgraded_wasbase_admin_vmware` | `dpi_upgraded_wasbase_admin_vmware_amer_prd_core` | `iv2amer` | CORE | false |
| 24 | EMEA | DEV | `wasnd` | `wasnd_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 25 | APAC | DEV | `wasnd` | `wasnd_apac_dev_core` | `iv2apac` | CORE | false |
| 26 | APAC | STG | `wasnd` | `wasnd_apac_stg_core` | `iv2apac` | CORE | false |
| 27 | APAC | PRD | `wasnd` | `wasnd_apac_prd_core` | `iv2apac` | CORE | false |
| 28 | APAC | DEV | `dpi_upgraded_wasnd` | `dpi_upgraded_wasnd_apac_dev_core` | `iv2apac` | CORE | false |
| 29 | APAC | STG | `dpi_upgraded_wasnd` | `dpi_upgraded_wasnd_apac_stg_core` | `iv2apac` | CORE | false |
| 30 | APAC | PRD | `dpi_upgraded_wasnd` | `dpi_upgraded_wasnd_apac_prd_core` | `iv2apac` | CORE | false |

## Miércoles - JBoss EAP

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `jbosseap` | `jbosseap_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 2 | EMEA | STG | `jbosseap` | `jbosseap_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 3 | EMEA | PRD | `jbosseap` | `jbosseap_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 4 | AMER | DEV | `jbosseap` | `jbosseap_amer_dev_core` | `iv2amer` | CORE | false |
| 5 | AMER | STG | `jbosseap` | `jbosseap_amer_stg_core` | `iv2amer` | CORE | false |
| 6 | AMER | PRD | `jbosseap` | `jbosseap_amer_prd_core` | `iv2amer` | CORE | false |
| 7 | APAC | DEV | `jbosseap` | `jbosseap_apac_dev_core` | `iv2apac` | CORE | false |
| 8 | APAC | STG | `jbosseap` | `jbosseap_apac_stg_core` | `iv2apac` | CORE | false |
| 9 | APAC | PRD | `jbosseap` | `jbosseap_apac_prd_core` | `iv2apac` | CORE | false |
| 10 | EMEA | DEV | `csa_imported_jbosseap` | `csa_imported_jbosseap_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 11 | EMEA | STG | `csa_imported_jbosseap` | `csa_imported_jbosseap_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 12 | EMEA | PRD | `csa_imported_jbosseap` | `csa_imported_jbosseap_emea_prd_core` | `MiddlewareFR` | CORE | false |

## Jueves - Tomcat

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `tomcat` | `tomcat_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 2 | EMEA | STG | `tomcat` | `tomcat_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 3 | EMEA | PRD | `tomcat` | `tomcat_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 4 | APAC | DEV | `tomcat` | `tomcat_apac_dev_core` | `iv2apac` | CORE | false |
| 5 | APAC | STG | `tomcat` | `tomcat_apac_stg_core` | `iv2apac` | CORE | false |
| 6 | APAC | PRD | `tomcat` | `tomcat_apac_prd_core` | `iv2apac` | CORE | false |
| 7 | AMER | DEV | `tomcat` | `tomcat_amer_dev_core` | `iv2amer` | CORE | false |
| 8 | AMER | PRD | `tomcat` | `tomcat_amer_prd_core` | `iv2amer` | CORE | false |
| 9 | EMEA | PRD | `tomcat` | `tomcat_emea_prd_ets` | `MiddlewareFR` | ETS | true |
| 10 | AMER | PRD | `tomcat` | `tomcat_amer_prd_ets` | `iv2amer` | ETS | true |
| 11 | EMEA | DEV | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 12 | EMEA | STG | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 13 | EMEA | PRD | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 14 | APAC | DEV | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_apac_dev_core` | `iv2apac` | CORE | false |
| 15 | APAC | STG | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_apac_stg_core` | `iv2apac` | CORE | false |
| 16 | APAC | PRD | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_apac_prd_core` | `iv2apac` | CORE | false |
| 17 | AMER | DEV | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_amer_dev_core` | `iv2amer` | CORE | false |
| 18 | AMER | STG | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_amer_stg_core` | `iv2amer` | CORE | false |
| 19 | AMER | PRD | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_amer_prd_core` | `iv2amer` | CORE | false |
| 20 | EMEA | PRD | `dpi_upgraded_tomcat` | `dpi_upgraded_tomcat_emea_prd_ets` | `MiddlewareFR` | ETS | true |
| 21 | AMER | DEV | `tomcat_ibm` | `tomcat_ibm_amer_dev_mzr` | `iv2amer` | MZR | false |
| 22 | AMER | STG | `tomcat_ibm` | `tomcat_ibm_amer_stg_mzr` | `iv2amer` | MZR | false |
| 23 | AMER | PRD | `tomcat_ibm` | `tomcat_ibm_amer_prd_mzr` | `iv2amer` | MZR | false |
| 24 | EMEA | DEV | `tomcat_ibmcloud_vpc` | `tomcat_ibmcloud_vpc_emea_dev_mzr` | `MiddlewareFR` | MZR | false |
| 25 | EMEA | STG | `tomcat_ibmcloud_vpc` | `tomcat_ibmcloud_vpc_emea_stg_mzr` | `MiddlewareFR` | MZR | false |
| 26 | EMEA | PRD | `tomcat_ibmcloud_vpc` | `tomcat_ibmcloud_vpc_emea_prd_mzr` | `MiddlewareFR` | MZR | false |
| 27 | EMEA | DEV | `jboss_ews` | `jboss_ews_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 28 | EMEA | STG | `jboss_ews` | `jboss_ews_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 29 | EMEA | PRD | `jboss_ews` | `jboss_ews_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 30 | APAC | DEV | `jboss_ews` | `jboss_ews_apac_dev_core` | `iv2apac` | CORE | false |
| 31 | APAC | STG | `jboss_ews` | `jboss_ews_apac_stg_core` | `iv2apac` | CORE | false |
| 32 | APAC | PRD | `jboss_ews` | `jboss_ews_apac_prd_core` | `iv2apac` | CORE | false |
| 33 | AMER | DEV | `jboss_ews` | `jboss_ews_amer_dev_core` | `iv2amer` | CORE | false |
| 34 | AMER | STG | `jboss_ews` | `jboss_ews_amer_stg_core` | `iv2amer` | CORE | false |
| 35 | AMER | PRD | `jboss_ews` | `jboss_ews_amer_prd_core` | `iv2amer` | CORE | false |

## Viernes - Apache

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `apache_dmzi` | `apache_dmzi_emea_dev_dmzi` | `MiddlewareFR` | DMZI | false |
| 2 | EMEA | STG | `apache_dmzi` | `apache_dmzi_emea_stg_dmzi` | `MiddlewareFR` | DMZI | false |
| 3 | EMEA | PRD | `apache_dmzi` | `apache_dmzi_emea_prd_dmzi` | `MiddlewareFR` | DMZI | false |
| 4 | APAC | DEV | `apache_dmzi` | `apache_dmzi_apac_dev_dmzi` | `iv2apac` | DMZI | false |
| 5 | APAC | STG | `apache_dmzi` | `apache_dmzi_apac_stg_dmzi` | `iv2apac` | DMZI | false |
| 6 | APAC | PRD | `apache_dmzi` | `apache_dmzi_apac_prd_dmzi` | `iv2apac` | DMZI | false |
| 7 | AMER | STG | `apache_dmzi` | `apache_dmzi_amer_stg_dmzi` | `iv2amer` | DMZI | false |
| 8 | AMER | PRD | `apache_dmzi` | `apache_dmzi_amer_prd_dmzi` | `iv2amer` | DMZI | false |
| 9 | APAC | DEV | `apache_dmzi_apac` | `apache_dmzi_apac_apac_dev_dmzi` | `iv2apac` | DMZI | false |
| 10 | APAC | STG | `apache_dmzi_apac` | `apache_dmzi_apac_apac_stg_dmzi` | `iv2apac` | DMZI | false |
| 11 | APAC | PRD | `apache_dmzi_apac` | `apache_dmzi_apac_apac_prd_dmzi` | `iv2apac` | DMZI | false |
| 12 | EMEA | DEV | `apache_dmzi_emea` | `apache_dmzi_emea_emea_dev_dmzi` | `MiddlewareFR` | DMZI | false |
| 13 | EMEA | STG | `apache_dmzi_emea` | `apache_dmzi_emea_emea_stg_dmzi` | `MiddlewareFR` | DMZI | false |
| 14 | EMEA | PRD | `apache_dmzi_emea` | `apache_dmzi_emea_emea_prd_dmzi` | `MiddlewareFR` | DMZI | false |
| 15 | AMER | STG | `apache_dmzi_amer` | `apache_dmzi_amer_amer_stg_dmzi` | `iv2amer` | DMZI | false |
| 16 | AMER | PRD | `apache_dmzi_amer` | `apache_dmzi_amer_amer_prd_dmzi` | `iv2amer` | DMZI | false |
| 17 | EMEA | DEV | `apache` | `apache_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 18 | EMEA | STG | `apache` | `apache_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 19 | EMEA | PRD | `apache` | `apache_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 20 | APAC | DEV | `apache` | `apache_apac_dev_core` | `iv2apac` | CORE | false |
| 21 | APAC | STG | `apache` | `apache_apac_stg_core` | `iv2apac` | CORE | false |
| 22 | APAC | PRD | `apache` | `apache_apac_prd_core` | `iv2apac` | CORE | false |
| 23 | AMER | DEV | `apache` | `apache_amer_dev_core` | `iv2amer` | CORE | false |
| 24 | AMER | STG | `apache` | `apache_amer_stg_core` | `iv2amer` | CORE | false |
| 25 | AMER | PRD | `apache` | `apache_amer_prd_core` | `iv2amer` | CORE | false |
| 26 | EMEA | PRD | `apache` | `apache_emea_prd_ets` | `MiddlewareFR` | ETS | true |
| 27 | AMER | PRD | `apache` | `apache_amer_prd_ets` | `iv2amer` | ETS | true |
| 28 | EMEA | DEV | `apache_wsgi` | `apache_wsgi_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 29 | EMEA | STG | `apache_wsgi` | `apache_wsgi_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 30 | EMEA | PRD | `apache_wsgi` | `apache_wsgi_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 31 | EMEA | STG | `csa_imported_apache_dmzi_emea` | `csa_imported_apache_dmzi_emea_emea_stg_dmzi` | `MiddlewareFR` | DMZI | false |
| 32 | EMEA | PRD | `csa_imported_apache_dmzi_emea` | `csa_imported_apache_dmzi_emea_emea_prd_dmzi` | `MiddlewareFR` | DMZI | false |
| 33 | EMEA | DEV | `dpi_upgraded_apache` | `dpi_upgraded_apache_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 34 | EMEA | STG | `dpi_upgraded_apache` | `dpi_upgraded_apache_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 35 | EMEA | PRD | `dpi_upgraded_apache` | `dpi_upgraded_apache_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 36 | APAC | DEV | `dpi_upgraded_apache` | `dpi_upgraded_apache_apac_dev_core` | `iv2apac` | CORE | false |
| 37 | APAC | STG | `dpi_upgraded_apache` | `dpi_upgraded_apache_apac_stg_core` | `iv2apac` | CORE | false |
| 38 | APAC | PRD | `dpi_upgraded_apache` | `dpi_upgraded_apache_apac_prd_core` | `iv2apac` | CORE | false |
| 39 | AMER | DEV | `dpi_upgraded_apache` | `dpi_upgraded_apache_amer_dev_core` | `iv2amer` | CORE | false |
| 40 | AMER | STG | `dpi_upgraded_apache` | `dpi_upgraded_apache_amer_stg_core` | `iv2amer` | CORE | false |
| 41 | AMER | PRD | `dpi_upgraded_apache` | `dpi_upgraded_apache_amer_prd_core` | `iv2amer` | CORE | false |
| 42 | EMEA | PRD | `dpi_upgraded_apache` | `dpi_upgraded_apache_emea_prd_ets` | `MiddlewareFR` | ETS | true |
| 43 | EMEA | DEV | `sso_as_a_service` | `sso_as_a_service_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 44 | EMEA | STG | `sso_as_a_service` | `sso_as_a_service_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 45 | EMEA | PRD | `sso_as_a_service` | `sso_as_a_service_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 46 | APAC | DEV | `sso_as_a_service` | `sso_as_a_service_apac_dev_core` | `iv2apac` | CORE | false |
| 47 | APAC | STG | `sso_as_a_service` | `sso_as_a_service_apac_stg_core` | `iv2apac` | CORE | false |
| 48 | APAC | PRD | `sso_as_a_service` | `sso_as_a_service_apac_prd_core` | `iv2apac` | CORE | false |
| 49 | AMER | DEV | `sso_as_a_service` | `sso_as_a_service_amer_dev_core` | `iv2amer` | CORE | false |
| 50 | AMER | STG | `sso_as_a_service` | `sso_as_a_service_amer_stg_core` | `iv2amer` | CORE | false |
| 51 | AMER | PRD | `sso_as_a_service` | `sso_as_a_service_amer_prd_core` | `iv2amer` | CORE | false |
| 52 | EMEA | DEV | `sso_as_a_service` | `sso_as_a_service_ibm_dmzr_emea_dev_mzr` | `MiddlewareFR` | MZR | false |
| 53 | EMEA | STG | `sso_as_a_service` | `sso_as_a_service_ibm_dmzr_emea_stg_mzr` | `MiddlewareFR` | MZR | false |
| 54 | EMEA | PRD | `sso_as_a_service` | `sso_as_a_service_ibm_dmzr_emea_prd_mzr` | `MiddlewareFR` | MZR | false |
| 55 | AMER | DEV | `sso_as_a_service_ibm_vdc` | `sso_as_a_service_ibm_vdc_amer_dev_intranet` | `iv2amer` | DMZI | false |
| 56 | AMER | STG | `sso_as_a_service_ibm_vdc` | `sso_as_a_service_ibm_vdc_amer_stg_intranet` | `iv2amer` | DMZI | false |
| 57 | AMER | PRD | `sso_as_a_service_ibm_vdc` | `sso_as_a_service_ibm_vdc_amer_prd_intranet` | `iv2amer` | DMZI | false |
| 58 | EMEA | DEV | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 59 | EMEA | STG | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 60 | EMEA | PRD | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 61 | APAC | DEV | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_apac_dev_core` | `iv2apac` | CORE | false |
| 62 | APAC | STG | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_apac_stg_core` | `iv2apac` | CORE | false |
| 63 | APAC | PRD | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_apac_prd_core` | `iv2apac` | CORE | false |
| 64 | AMER | DEV | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_amer_dev_core` | `iv2amer` | CORE | false |
| 65 | AMER | STG | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_amer_stg_core` | `iv2amer` | CORE | false |
| 66 | AMER | PRD | `dpi_upgraded_sso_as_a_service` | `dpi_upgraded_sso_as_a_service_amer_prd_core` | `iv2amer` | CORE | false |
| 67 | AMER | STG | `apache_ibm` | `apache_ibm_amer_stg_mzr` | `iv2amer` | MZR | false |
| 68 | AMER | PRD | `apache_ibm` | `apache_ibm_amer_prd_mzr` | `iv2amer` | MZR | false |
| 69 | EMEA | DEV | `apache_ibmcloud_vpc` | `apache_ibmcloud_vpc_emea_dev_mzr` | `MiddlewareFR` | MZR | false |
| 70 | EMEA | STG | `apache_ibmcloud_vpc` | `apache_ibmcloud_vpc_emea_stg_mzr` | `MiddlewareFR` | MZR | false |
| 71 | EMEA | PRD | `apache_ibmcloud_vpc` | `apache_ibmcloud_vpc_emea_prd_mzr` | `MiddlewareFR` | MZR | false |

## Sábado - IIS

| # | region | envs | product | limit | IG | zone | is_ETS |
|---:|---|---|---|---|---|---|---|
| 1 | EMEA | DEV | `iis_all_windows_version` | `iis_all_windows_version_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 2 | EMEA | STG | `iis_all_windows_version` | `iis_all_windows_version_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 3 | EMEA | PRD | `iis_all_windows_version` | `iis_all_windows_version_emea_prd_core` | `MiddlewareFR` | CORE | false |
| 4 | EMEA | DEV | `dpi_upgraded_iis_all_windows_version_vmware` | `dpi_upgraded_iis_all_windows_version_vmware_emea_dev_core` | `MiddlewareFR` | CORE | false |
| 5 | EMEA | STG | `dpi_upgraded_iis_all_windows_version_vmware` | `dpi_upgraded_iis_all_windows_version_vmware_emea_stg_core` | `MiddlewareFR` | CORE | false |
| 6 | EMEA | PRD | `dpi_upgraded_iis_all_windows_version_vmware` | `dpi_upgraded_iis_all_windows_version_vmware_emea_prd_core` | `MiddlewareFR` | CORE | false |

## Ejemplo especial ETS

Entrada:

```text
EMEA|PRD|apache|apache_emea_prd_ets|none|ETS
```

Extra Variables:

```yaml
region: EMEA
envs: PRD
product: apache
limit: apache_emea_prd_ets
update: update
instance_group: MiddlewareFR
data_env: prod
is_ETS: "true"
location_zone: ETS
```

## Ejemplo APAC

Entrada:

```text
APAC|PRD|tomcat|tomcat_apac_prd_core|iv2apac|CORE
```

Extra Variables:

```yaml
region: APAC
envs: PRD
product: tomcat
limit: tomcat_apac_prd_core
update: update
instance_group: iv2apac
data_env: prod
is_ETS: "false"
location_zone: CORE
```

## Ejemplo AMER

Entrada:

```text
AMER|PRD|apache|apache_amer_prd_core|iv2amer|CORE
```

Extra Variables:

```yaml
region: AMER
envs: PRD
product: apache
limit: apache_amer_prd_core
update: update
instance_group: iv2amer
data_env: prod
is_ETS: "false"
location_zone: CORE
```

# Cutover

Una vez creados y validados los 161 schedules:

```text
Tower Schedule
    |
    v
Elastic_TESTING
    |
    v
role actual
```

se retiran de la ejecución:

```text
crontab RHEL
run_awx_all.sh
awx_prompt.sh
```

Los scripts pueden conservarse temporalmente fuera del flujo únicamente como referencia/rollback durante la validación inicial.

## Validación antes de retirar el cron

Para cada familia debe comprobarse:

- Número de schedules igual al número de entradas anterior.
- Día semanal correcto.
- Separación temporal equivalente a los 60 segundos anteriores.
- `region` correcto.
- `envs` correcto.
- `product` correcto.
- `limit` correcto.
- `instance_group` transformado correctamente.
- `location_zone` correcto.
- `is_ETS` correcto.
- `update: update`.
- `data_env: prod`.
- Ejecución directa del Job Template `Elastic_TESTING`.
- Resultado funcional equivalente al lanzamiento anterior por AWX CLI.
