#! /bin/bash

#test -z "$PROJECT_NAME" && PROJECT_NAME="$APP_SUB-$ENVIRONMENT_ID"
#test -z "$NAMESPACE"    &&    NAMESPACE="$app_prj-$app_env"
#test -z "$APP_NAME"     &&     APP_NAME="$APP_SUB"

KubectlGet(){
    case $1 in
        svc|SVC)    kubectl get svc          -n $NAMESPACE ;;
        deploy)     kubectl get deploy       -n $NAMESPACE ;;
        rs|RS)      kubectl get rs   -o wide -n $NAMESPACE ;;
        pods|Pods)  kubectl get pods -o wide -n $NAMESPACE ;;
        ClusterIP)  KubectlGet SVC | awk '{print $3}'      ;;
    esac
}

KubeController(){
    test "$SKIP_KUBE" = "true"  && \
    msg i "Skip KubeController" && \
    return 0

    load replace

     f_rc="Deployments.yaml"
    f_svc="Service.yaml"

    check file $f_rc

    test -f $f_rc  && f_lists="$f_rc"
    test -f $f_svc && f_lists="$f_lists $f_svc"

    ReplaceKubeFile

    DockerfileBackup

    if [ -f $f_svc ]
    then
        msg i "Check service $PROJECT_NAME"
        KubectlGet SVC | grep -q "^$PROJECT_NAME "

        if [ $? = 0 ]
        then
            msg a "Service $PROJECT_NAME already exist"
        else
            msg a "Create $PROJECT_NAME"
            kubectl create -f $f_svc
        fi
    fi

    msg i "Check deployment $PROJECT_NAME"
    KubectlGet deploy | grep -q "$PROJECT_NAME "
    if [ $? = 0 ]
    then
        if [ "$DEPLOY_CREATE_OR_UPDATE" != "create" ]
        then
            msg a "Update Deployment $PROJECT_NAME set image to  $DOCKER_IMAGE_NAME:$DOCKER_TAG"
            kubectl set image deploy/$PROJECT_NAME $PROJECT_NAME=$DOCKER_IMAGE_NAME:$DOCKER_TAG -n $NAMESPACE
        else
            msg i "Removing Deployment $PROJECT_NAME"
            kubectl delete -f $f_rc

            msg i "Creating Deployment $PROJECT_NAME"
            kubectl create -f $f_rc
        fi
    else
        msg a "No results found. Create Deployment $PROJECT_NAME"
        kubectl create -f $f_rc
    fi

    test $? = 0 && msg d "Successfully completed" || msg e "Failed"
}
