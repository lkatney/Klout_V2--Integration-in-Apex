public class abc{
public string s;
public integer n;
public abc()
{AsyncApexJob Ajob= new AsyncApexJob();
Ajob=[SELECT ApexClassId,completedDate FROM AsyncApexJob where apexclassID='01p90000001SUnCAAW' limit 1];
if(Ajob==null)
{
s='Select id from account limit 2500';
n=0;
}
else
{if(Ajob.completeddate==null)
{
s='Select id from account limit 2500';
n=0;
}
else
{
s='Select id from account ORDER BY createdDate DESC limit 2500';
n=1;
}
}
system.debug('Query number:'+n);
}
}