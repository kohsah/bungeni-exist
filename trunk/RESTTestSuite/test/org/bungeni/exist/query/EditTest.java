package org.bungeni.exist.query;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.custommonkey.xmlunit.SimpleNamespaceContext;
import static org.custommonkey.xmlunit.XMLAssert.assertXMLEqual;
import org.custommonkey.xmlunit.XMLUnit;
import org.custommonkey.xmlunit.XpathEngine;
import org.custommonkey.xmlunit.exceptions.XpathException;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * Test harness for Bungeni XQuery REST API
 * http://localhost:8088/db/bungeni/query/edit.xql
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.1
 */
public class EditTest
{
    static {
        XMLUnit.setIgnoreWhitespace(true);
    }

    /**
     * Attempts to store a NEW XML document
     * checks the returned document is the same as the posted document
     */
    @Test
    public void storeNewXMLDocument()
    {
        String testDocManifestationURI = "/ken/act/2008-07-04/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        storeTestDocument(AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.ORIGINAL_VERSION, testDocWorkURI, testDocExpressionURI, testDocManifestationURI, null), testDocManifestationURI);
    }

    /**
     * GETs a un-versioned XML document
     * and then POSTs it back to the server
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void updateUnVersionedXMLDocument()
    {
        String testDocManifestationURI = "/ken/bill/2008-07-04/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        //store a test document, we can then try updating it
        storeTestDocument(AkomaNtoso.generateTestBill(testDocWorkURI, testDocExpressionURI, testDocManifestationURI), testDocManifestationURI);

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //GET the binary document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
        };
        get.setQueryString(qsGetParams);

        byte getDocument[] = null;
        try
        {
                status = http.executeMethod(get);
                getDocument = REST.getResponseBody(get);

                assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);
        }
        catch(IOException ioe)
        {
                ioe.printStackTrace();
                fail(ioe.getMessage());
        }
        finally
        {
                //release the connection
                get.releaseConnection();
        }

        //POST the updated XML document
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);
        NameValuePair qsPostParams[] = {
                        new NameValuePair("action", "save"),
                        new NameValuePair("uri", testDocManifestationURI),
                };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

        try
        {
                status = http.executeMethod(post);

                assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

                InputStream responseDocument = post.getResponseBodyAsStream();
                assertXMLEqual("Document should not have changed", new InputSource(new ByteArrayInputStream(getDocument)), new InputSource(responseDocument));
        }
        catch(IOException ioe)
        {
                ioe.printStackTrace();
                fail(ioe.getMessage());
        }
        catch(SAXException se)
        {
                se.printStackTrace();
                fail(se.getMessage());
        }
        finally
        {
                //release the connection
                post.releaseConnection();
        }
    }

    /**
     * GETs a versioned XML document for editing
     * and then POSTs the new version back to the server for store
     *
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void createNewXMLDocumentVersion()
    {
        String testDocManifestationURI = "/ken/act/2008-07-05/1/eng.xml";
        String testDocExpressionURI = testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.'));
        String testDocWorkURI = testDocExpressionURI.substring(0, testDocExpressionURI.lastIndexOf('/'));

        //store a test document, we can then create a version of it
        storeTestDocument(AkomaNtoso.generateTestAct(AkomaNtoso.ActContentTypes.SINGLE_VERSION, testDocWorkURI, testDocExpressionURI, testDocManifestationURI, null), testDocManifestationURI);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String newVersion = sdf.format(Calendar.getInstance().getTime());

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //GET the XML document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
                new NameValuePair("version", newVersion)
        };
        get.setQueryString(qsGetParams);

        byte getResponse[] = null;
        try
        {
                status = http.executeMethod(get);
                getResponse = REST.getResponseBody(get);

                assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

                assertTrue("No Response document", getResponse != null && getResponse.length > 0);

                //check the document URI's have been updated for the new version
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                factory.setFeature("http://xml.org/sax/features/namespaces", true);
                DocumentBuilder builder = factory.newDocumentBuilder();
                Document docVersioned = builder.parse(new ByteArrayInputStream(getResponse));
                XpathEngine xpathEngine = XMLUnit.newXpathEngine();

                HashMap<String, String> namespaces = new HashMap<String, String>();
                namespaces.put("an", AkomaNtoso.NAMESPACE_URI);
                xpathEngine.setNamespaceContext(new SimpleNamespaceContext(namespaces));
                String versionedExpressionURI = xpathEngine.evaluate("/an:akomantoso/an:act/an:meta/an:identification/an:Expression/an:uri/@href", docVersioned);
                String versionedManifestationURI = xpathEngine.evaluate("/an:akomantoso/an:act/an:meta/an:identification/an:Manifestation/an:uri/@href", docVersioned);

                assertEquals(versionedExpressionURI, testDocExpressionURI + "@" + newVersion);
                assertEquals(versionedManifestationURI, testDocManifestationURI.substring(0, testDocManifestationURI.indexOf('.')) + "@" + newVersion + testDocManifestationURI.substring(testDocManifestationURI.indexOf('.')));
            }
            catch (XpathException xpe)
            {
                xpe.printStackTrace();
                fail(xpe.getMessage());
            }
            catch(ParserConfigurationException pce)
            {
                pce.printStackTrace();
                fail(pce.getMessage());
            }
            catch(SAXException se)
            {
                se.printStackTrace();
                fail(se.getMessage());
            }
            catch(IOException ioe)
            {
                ioe.printStackTrace();
                fail(ioe.getMessage());
            }
            finally
            {
                //release the connection
                get.releaseConnection();
            }

            //add a reference to the Original version into the new version of the document
            String originalReference = "<an:references source=\"#ar1\"><an:Original id=\"ro1\" href=\"" + testDocManifestationURI + "\" showAs=\"Original\"/></an:references>";
            String newDocVersion = new String(getResponse);
            newDocVersion = newDocVersion.substring(0, newDocVersion.indexOf("</an:meta>")) + originalReference + newDocVersion.substring(newDocVersion.indexOf("</an:meta>"));

            //POST the new version XML document
            byte[] postDocument = null;
            PostMethod post = new PostMethod(REST.EDIT_URL);
            post.setDoAuthentication(true);
            NameValuePair qsPostParams[] = {
                            new NameValuePair("action", "save"),
                            new NameValuePair("uri", testDocManifestationURI),
                            new NameValuePair("version", newVersion)
                    };
            post.setQueryString(qsPostParams);
            post.setRequestEntity(new ByteArrayRequestEntity(newDocVersion.getBytes(), Database.XML_MIMETYPE));

            try
            {
                    status = http.executeMethod(post);

                    assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

                    InputStream responseDocument = post.getResponseBodyAsStream();
                    assertXMLEqual("Response document did not match uploaded document", new InputSource(new StringReader(newDocVersion)), new InputSource(responseDocument));
            }
            catch(IOException ioe)
            {
                    ioe.printStackTrace();
                    fail(ioe.getMessage());
            }
            catch(SAXException se)
            {
                    se.printStackTrace();
                    fail(se.getMessage());
            }
            finally
            {
                    //release the connection
                    post.releaseConnection();
            }
    }

    /**
     * GETs a binary un-versioned document
     * and then POSTs it back to the server
     * it checks that the documents content
     * is the same between the GET response and POST response
     */
    @Test
    public void updateUnVersionedBinaryDocument()
    {
        String testDocManifestationURI = "/ken/act/1997-08-22/3/eng.doc";

        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //GET the binary document
        GetMethod get = new GetMethod(REST.EDIT_URL);
        get.setDoAuthentication(true);

        //set the querystring
        NameValuePair qsGetParams[] = {
                new NameValuePair("uri", testDocManifestationURI),
        };
        get.setQueryString(qsGetParams);

        byte getDocument[] = null;
        try
        {
            status = http.executeMethod(get);
            getDocument = REST.getResponseBody(get);

            assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

            assertTrue("No Response document", getDocument != null && getDocument.length > 0);
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            //release the connection
            get.releaseConnection();
        }

        //POST the updated binary document
        byte[] postDocument = null;
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);
        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "save"),
            new NameValuePair("uri", testDocManifestationURI),
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

        try
        {
            status = http.executeMethod(post);
            postDocument = REST.getResponseBody(post);

            assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

            if(postDocument != null && getDocument != null && postDocument.length == getDocument.length)
            {
                    for(int i = 0; i < postDocument.length; i++)
                    {
                            assertEquals("Received document is not the same as the saved document", postDocument[i], getDocument[i]);
                    }
            }
            else
            {
                    fail("Received document is not the same as the saved document");
            }
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        finally
        {
            //release the connection
            post.releaseConnection();
        }
    }

    /**
     * GETs a binary versioned document
     * and then POSTs it back to the server
     * it checks that the new version of the document
     * has the same content as the original version
     */
    @Test
    public void createNewBinaryDocumentVersion()
    {
            final String testDocManifestationURI = "/ken/act/1997-08-22/3/eng.doc";
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String newVersion = sdf.format(Calendar.getInstance().getTime());

            HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
            int status = HttpStatus.SC_NOT_FOUND;

            //GET the binary document
            GetMethod get = new GetMethod(REST.EDIT_URL);
            get.setDoAuthentication(true);

            //set the querystring
            NameValuePair qsGetParams[] = {
                    new NameValuePair("uri", testDocManifestationURI),
                    new NameValuePair("version", newVersion)
            };
            get.setQueryString(qsGetParams);

            byte getDocument[] = null;
            try
            {
                    status = http.executeMethod(get);
                    getDocument = REST.getResponseBody(get);

                    assertEquals("GET Request did not return OK", HttpStatus.SC_OK, status);

                    assertTrue("No Response document", getDocument != null && getDocument.length > 0);
            }
            catch(IOException ioe)
            {
                    ioe.printStackTrace();
                    fail(ioe.getMessage());
            }
            finally
            {
                    //release the connection
                    get.releaseConnection();
            }

            //POST the updated binary document
            byte[] postDocument = null;
            PostMethod post = new PostMethod(REST.EDIT_URL);
            post.setDoAuthentication(true);
            NameValuePair qsPostParams[] = {
                            new NameValuePair("action", "save"),
                            new NameValuePair("uri", testDocManifestationURI),
                            new NameValuePair("version", newVersion)
                    };
            post.setQueryString(qsPostParams);
            post.setRequestEntity(new ByteArrayRequestEntity(getDocument, get.getResponseHeader("Content-Type").getValue()));

            try
            {
                    status = http.executeMethod(post);
                    postDocument = REST.getResponseBody(post);

                    assertEquals("POST Request did not return OK", HttpStatus.SC_OK, status);

                    if(postDocument != null && getDocument != null && postDocument.length == getDocument.length)
                    {
                            for(int i = 0; i < postDocument.length; i++)
                            {
                                    assertEquals("Received document is not the same as the saved document", postDocument[i], getDocument[i]);
                            }
                    }
                    else
                    {
                            fail("Received document is not the same as the saved document");
                    }
            }
            catch(IOException ioe)
            {
                    ioe.printStackTrace();
                    fail(ioe.getMessage());
            }
            finally
            {
                    post.releaseConnection();
            }
    }

    /**
     * Stores a XML Test document for testing against
     *
     * @param testDocument the XML test document
     * @param manifestationURI the URI of this Manifestation
     */
    private final static void storeTestDocument(String testDocument, String manifestationURI)
    {
        HttpClient http = REST.getAuthenticatingHttpClient(Database.DEFAULT_ADMIN_USERNAME, Database.DEFAULT_ADMIN_PASSWORD);
        int status = HttpStatus.SC_NOT_FOUND;

        //setup POST Request for storing new document
        PostMethod post = new PostMethod(REST.EDIT_URL);
        post.setDoAuthentication(true);

        //String testDocument = generateAct(actContentType, workURI, expressionURI, manifestationURI, originalURI);

        NameValuePair qsPostParams[] = {
            new NameValuePair("action", "new"),
            new NameValuePair("uri", manifestationURI)
        };
        post.setQueryString(qsPostParams);
        post.setRequestEntity(new ByteArrayRequestEntity(testDocument.getBytes(), Database.XML_MIMETYPE));

        try
        {
            //do POST Request
            status = http.executeMethod(post);
            assertEquals("POST Request did not return HTTP OK", HttpStatus.SC_OK, status);

            InputStream responseDocument = post.getResponseBodyAsStream();
            assertXMLEqual("Response document did not match uploaded document", new InputSource(new StringReader(testDocument)), new InputSource(responseDocument));
        }
        catch(IOException ioe)
        {
            ioe.printStackTrace();
            fail(ioe.getMessage());
        }
        catch(SAXException se)
        {
            se.printStackTrace();
            fail(se.getMessage());
        }
        finally
        {
            //release the connection
            post.releaseConnection();
        }
    }
}
