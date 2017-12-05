// Adapted from
// https://sourceforge.net/p/xmlrpc-c/code/HEAD/tree/trunk/examples/xmlrpc_sample_add_client.c
//


#include <stdlib.h>
#include <xmlrpc-c/base.h>
#include <xmlrpc-c/client.h>

#include "config.h"  // Site specific

#define NAME "XML-RPC C Test Client"
#define VERSION "1.0"



static void 
die_if_fault_occurred (xmlrpc_env * const envP) {
    if (envP->fault_occurred) {
        fprintf(stderr, "ERROR: %s (%d)\n",
                envP->fault_string, envP->fault_code);
        exit(1);
    }
}

int 
main(int           const argc, 
     const char ** const argv) {

    xmlrpc_env env;
    xmlrpc_client * clientP;
    xmlrpc_value * resultP;
    int found;
    char * const url = "http://localhost:8080/users";

    char * const testUser = "alec";


    /* Initialize our error-handling environment. */
    xmlrpc_env_init(&env);

    xmlrpc_client_setup_global_const(&env);

    xmlrpc_client_create(&env, XMLRPC_CLIENT_NO_FLAGS, NAME, VERSION, NULL, 0,
                         &clientP);
    die_if_fault_occurred(&env);

    /* Make the remote procedure call */
    xmlrpc_client_call2f(&env, clientP, url, "userExists", &resultP,
                "(s)", testUser );
    die_if_fault_occurred(&env);
    
    /* Get our result and print it out. */
    xmlrpc_read_bool(&env, resultP, &found);
    die_if_fault_occurred(&env);
    printf("The user %s %s\n", testUser, found? "exists": "does not exist");
    
    /* Dispose of our result value. Need to do this before we can use it again */
    xmlrpc_DECREF(resultP);

    /* Make the remote procedure call */
    xmlrpc_client_call2f(&env, clientP, url, "getUserAllDetails", &resultP,
                "(s)", testUser );

    xmlrpc_value * UUIDp;

    xmlrpc_struct_find_value(&env, resultP, "UUID", &UUIDp);

    if (UUIDp) {
        const char *  UUID;
        xmlrpc_read_string(&env, UUIDp, &UUID);
        printf("Called getUserAllDetails() on user %s\nUUID is %s\n", testUser, UUID);

        xmlrpc_DECREF(UUIDp); // Don't need this anymore
    } else
        printf("There is no member named 'UUID'");

    /* Dispose of our result value. */
    xmlrpc_DECREF(resultP);


    /* Clean up our error-handling environment. */
    xmlrpc_env_clean(&env);
    
    xmlrpc_client_destroy(clientP);

    xmlrpc_client_teardown_global_const();

    return 0;
}

