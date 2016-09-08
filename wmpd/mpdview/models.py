from __future__ import unicode_literals

from django.db import models
from django.utils import timezone

class UserIP(models.Model):
#    ip = models.IPAddressField(primary_key=True)
    ip = models.GenericIPAddressField(protocol='both', unpack_ipv4=True, unique=True)
    def __unicode__(self):
        return "%s" % self.ip

class MyModel(models.Model):
    pub_date = models.DateTimeField('date created', default=timezone.now)
    userip = models.ForeignKey(UserIP)
    def __unicode__(self):
        return "%s" % self.sign()
    def sign(self):
        signer = TimestampSigner(salt='modelsign314151')
        return signer.sign(self.uuid)
