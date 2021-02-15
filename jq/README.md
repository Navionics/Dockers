## Example of usage

```
echo -e "{
   \"eBooks\":[
      {
         \"language\":\"Pascal\",
\"edition\":\"third\"
      },
      {
         \"language\":\"Python\",
         \"edition\":\"four\"
      },
      {
         \"language\":\"SQL\",
         \"edition\":\"second\"
      }
   ]
}" | docker run -i navionics/jq .eBooks[].language

```
