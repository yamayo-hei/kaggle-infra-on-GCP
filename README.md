# 0. Overview
### description of this repository
This repository is to create kaggle environment on GCP.
notebook template working on GCP is here.()

### required applications
|  application  |  version  |  confirmation command  |
| ----------- | ------- | ------- |
|  gcloud SDK  |  >= 446.0.0  | gcloud --version |
|  terraform  |  >= v1.5.7  | terraform --version |

*************************************************************************************************************************

# 1. Set up 
**※This step is only first time**

### 1-1. Advance preparation
1. create a git repository from this repository template ([> How to create repository from template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template))
2. clone to your local machine
3. fix the following files

|  File path  |  Fixes  |
| ----------- | ------- |
|  README.md  |  put a value in the `{clone_url}`.  |
|  README.md  |  put a value in the `{instance_name}`.  |
|  README.md  |  put a value in the `{zone}`.  |

4. Push to remote

### 1-2. Set up GCP VM Instance
1. If not exists, create your GCP account.
2. In GCP
    - create service account key and download private key(json file).
    - request the following quotas increase. (Approval takes about 1 hour)
        - NVIDIA T4 GPUs
        - GPUs (all regions)
3. In your local terminal
    - change directory to kaggle-infra-on-GCP/
    - change each setting value in variable.tf
    - execute following command
       ```
       gcloud init
       terraform init
       terraform plan
       terraform apply
       ```
    - ssh connect
       ```
       gcloud compute ssh {instance_name} --tunnel-through-iap --zone={zone}
       ```

4. In VM Instance
    - generate SSH key
      ```
      ssh-keygen
      ```
    - copy below command result to github setting
      ```
      cat ~/.ssh/id_rsa.pub
      ```
    - register output to your git hub account.
    - git clone
       ```
       git clone {clone_url}
       ```
    - Install nvidia driver
      ```
        ubuntu-drivers devices
        sudo apt -y install nvidia-driver-{recommended version}
        sudo reboot
      ```
# 2. Start
### 2-1. Start VM Instance
1. If the VM Instance is not ready, start the VM Instance in GCP.
# 3. Shutdown
### 3-1. Shutdown VM Instance
1. Stop the VM Instance in GCP.

# 4. Delete
### 4-1. Delete all environment
1. In your local terminal
    - change directory to kaggle-infra-on-GCP/
    - execute following command
       ```
       terraform destroy
       ```

