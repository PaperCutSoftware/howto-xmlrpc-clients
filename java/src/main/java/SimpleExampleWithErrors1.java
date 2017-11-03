//package com.github.papercutsoftware.howtoxmlrpcclients;
//
// Adapted from example on https://ws.apache.org/xmlrpc/client.html

import org.apache.xmlrpc.client.XmlRpcClient;
import org.apache.xmlrpc.client.XmlRpcClientConfigImpl;
import org.apache.xmlrpc.XmlRpcException;

import java.net.URL;
import java.net.MalformedURLException;


public class SimpleExampleWithErrors1 {

    private final static String host = "localhost";
    private final static String port = "8080";
    private final static String urlEndPoint = "http://"+host+":"+port+"/users";
    private final static String wrongUrlEndPoint = "http://"+host+":"+port+"/notcorrect";
    private final static String testUser = "alec";


    private static XmlRpcClientConfigImpl config;
    private static XmlRpcClient proxy;

    public static void main(String[] args) throws MalformedURLException {

        config = new XmlRpcClientConfigImpl();
        config.setServerURL(new URL(wrongUrlEndPoint));

        proxy= new XmlRpcClient();
        proxy.setConfig(config);

        try {
          Object[] params = new Object[]{testUser};
          boolean res = (boolean) proxy.execute("userExist",params);
          System.out.println("Called userExists for user " + testUser + ": Result is  " + res);
        } catch (XmlRpcException ex) {

          System.out.println("Caught XML RPC Exception " + ex.getMessage());
        }

        config.setServerURL(new URL(urlEndPoint));

        proxy.setConfig(config);

        try {
          Object[] params = new Object[]{testUser, new Integer(21)};
          boolean res = (boolean) proxy.execute("userExist",params);
          System.out.println("Called userExists for user " + testUser + ": Result is  " + res);
        } catch (XmlRpcException ex) {

          System.out.println("Caught XML RPC Exception " + ex.getMessage());
        }


        String[] p = new String[]{"alec", "noOne"};
        for ( String name : p) {

          try {
            Object[] params = new Object[]{name};
            boolean res = (boolean) proxy.execute("userExist",params);
            System.out.println("Called userExists for user " + testUser + ": Result is  " + res);
          } catch (XmlRpcException ex) {

            System.out.println("Caught XML RPC Exception " + ex.getMessage());
          }

        }
    }
}
