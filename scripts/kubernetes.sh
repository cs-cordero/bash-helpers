#!/bin/bash

function k8s_get_namespace() {
    set +e
    if [[ $# -le 0 ]]; then
        printf "E: Requires a namespace.\n" >&2;
        printf "Usage: %s [namespace]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    MATCHES=$(kubectl get namespaces -o "json" | jq '.items[].metadata.name' | rg "$1");
    COUNT=$(echo "$MATCHES" | wc -l);
    if [[ $COUNT -eq 0 ]]; then
        printf "No namespaces found with %s.\n" "$1">&2;
        return 1;
    fi
    if [[ $COUNT -gt 1 ]]; then
        printf "More than one namespace found with %s.\n" "$1" >&2;
        return 1;
    fi
    echo "${MATCHES//\"/}";
    return 0
}

function k8s_get_first_pod() {
    set +e
    if [[ -z $1 ]]; then
        printf "E: Requires a namespace.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    if [[ -z $2 ]]; then
        printf "E: Requires an app-name.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    NAMESPACE=$(k8s_get_namespace "$1")
    POD=$(kubectl -n "$NAMESPACE" get pods -l app="$2" -o json | jq '.items[0].metadata.name' | sed 's/"//g')
    if [[ "$POD" == "null" ]]; then
        printf "No pod found.\n" >&2;
        return 1;
    fi
    echo "$POD"
    return 0
}

function k8s_exec_into_first_pod() {
    set +e
    if [[ -z $1 ]]; then
        printf "E: Requires a namespace.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    if [[ -z $2 ]]; then
        printf "E: Requires an app-name.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    NAMESPACE=$(k8s_get_namespace "$1")
    POD=$(k8s_get_first_pod "$NAMESPACE" "$2")
    kubectl -n "$NAMESPACE" exec -it "$POD" bash
}

function k8s_logs_from_first_pod() {
    set +e
    if [[ -z $1 ]]; then
        printf "E: Requires a namespace.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    if [[ -z $2 ]]; then
        printf "E: Requires an app-name.\n" >&2;
        printf "Usage: %s [namespace] [app]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    NAMESPACE=$(k8s_get_namespace "$1")
    POD=$(k8s_get_first_pod "$NAMESPACE" "$2")
    kubectl -n "$NAMESPACE" logs "$POD"
}

function k8s_pods_from_namespace() {
    set +e
    if [[ -z $1 ]]; then
        printf "E: Requires a namespace.\n" >&2;
        printf "Usage: %s [namespace]\n" "${FUNCNAME[0]}";
        return 1;
    fi

    NAMESPACE=$(k8s_get_namespace "$1")
    kubectl -n "$NAMESPACE" get pods
}


alias gopod=k8s_exec_into_first_pod
alias golog=k8s_logs_from_first_pod
alias getpods=k8s_pods_from_namespace
