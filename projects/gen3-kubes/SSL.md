# Settings for SSL in Gen3 Data Commons
The job of setting up and managing SSL(TLS) for any web site is not for the timid, especially if you have a private CA.

## Preperation
1. Decide on a URL for your site.
2. Generate a CSR
3. Get the CSR signed by a CA, or sign using your own CA
4. Generate certificate file with the cert, key, and CA certificates.  (PFX format)
5. Copy that file to the assets directory in Azure-Infrastrucutre
6. Edit the terraform.tfvars file and change the entries sslCertificatefile  and sslCertificatePassword to the needful.

Terraform will build the application gateway with the certificate installed, and as long as it matches your site URL, it will work.

## References
- [Create a PFX certificate](https://www.ssl.com/how-to/create-a-pfx-p12-certificate-file-using-openssl/)
- [Convert PEM to PFX certificate format](https://stackoverflow.com/questions/808669/convert-a-cert-pem-certificate-to-a-pfx-certificate)
- Create a [self signed certificate](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
- Use Azure Portal to [configure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/create-ssl-portal)
- 
