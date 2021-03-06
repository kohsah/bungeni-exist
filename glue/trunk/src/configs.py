"""
Created on Feb 14, 2013

All config related classes are placed here

@author: undesa
"""

import os
import ConfigParser

from parsers import ParsePipelineXML
from gen_utils import get_module_dir
from java.lang import Integer

# system file
__pipeline_configs__ = "pipeline_config.xml"
# auto generate file
__type_mappings__ = "type_mappings.xml"
__logical_mappings__ = "logical_mappings.xml"
__pipelines__ = "pipelines.xml"

def __type_mappings_file():
    return os.path.join(get_module_dir(), __type_mappings__)

def __pipelines_file():
    return os.path.join(get_module_dir(), __pipelines__)

def __pipeline_configs_file():
    return os.path.join(get_module_dir(), __pipeline_configs__)

def __logical_mappings_file():
    return os.path.join(get_module_dir(), __logical_mappings__)

class Config(object):
    """
    Provides access to the configuration file via ConfigParser
    """
    
    def __init__(self, cfg_file):
        self.cfg = ConfigParser.RawConfigParser()
        print "Reading config file : " , cfg_file
        self.cfg.read(cfg_file)
        print "Finished reading config_file "

    
    def get(self, section, key):
        return self.cfg.get(section, key)

    def items(self, section):
        return self.cfg.items(section)

class TransformerConfig(Config):
    """
    Configuration information for the Transformer
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}

    def using_queue(self):
        return self.get("general", "message_queue")
 
    def bungeni_custom(self):
        return self.get("general", "bungeni_custom_folder")
    
    def types_xml_from_bungeni_custom(self):
        return os.path.join(self.bungeni_custom(), "types.xml")
 
    def __bungeni_custom__(self):
        import imp
        bc = imp.load_source(
                "bungeni_custom", 
                os.path.join(
                    self.bungeni_custom(), 
                    "__init__.py"
                )
            )
        return bc        
 
    """
    ## legislature changes - june 2014
    def __legislature__(self):
        bc = self.__bungeni_custom__()
        return bc.legislature
    """

    def languages_info(self):
        bc = self.__bungeni_custom__()
        lang_info = {
            "allowed_languages": bc.zope_i18n_allowed_languages,
            "default_language": bc.default_language,
            "right_to_left_languages": bc.right_to_left_languages
        }
        return lang_info
        
    def chamber_type_name(self):
        return self.get("legislature_config", "chamber_type")
    
    def legislature_type_name(self):
        return self.get("legislature_config", "legislature_type")
    
    def input_folder(self):
        return self.get("general", "bungeni_docs_folder")

    def transformer_resources_folder(self):
        return self.get("general", "transformer_resources_folder")

    def get_xml_output_folder(self):
        return self.get("general", "xml_output_folder")

    def get_attachments_output_folder(self):
        return self.get("general","attachments_output_folder")

    def get_temp_files_folder(self):
        return self.get("general","temp_files_folder")

    def get_cache_file_folder(self):
        return self.get("general","cache_file_folder")
    
    def get_pipelines(self):
        '''
        WARNING : This can be called only after type_all_configs() has been called in the consumer
        This is a bit of hack - since the pipelines originally used to be part of configuration ini, 
        the API was left as is, but the pipelines are instead returned from auto-generated configuration 
        '''
        if len(self.dict_pipes) == 0:
            parse_pipe = ParsePipelineXML(__pipelines_file())
            parse_pipe.doc_parse()
            for pipe in parse_pipe.get_pipelines():
                type_name = pipe.attributeValue("for")
                pipe = pipe.attributeValue("pipeline")
                self.dict_pipes[type_name] = pipe
        return self.dict_pipes
    
    def get_postprocess_action(self):
        return self.get("postprocess", "action")
    
    def get_postprocess_archive(self):
        return self.get("postprocess", "archive_folder")
    
    '''
    def get_pipelines(self):
        # list of key,values pairs as tuples 
        if len(self.dict_pipes) == 0:
            l_pipes = self.cfg.items("pipelines")
            for l_pipe in l_pipes:
                self.dict_pipes[l_pipe[0]] = l_pipe[1]
        return self.dict_pipes
    '''

class RabbitMqConfig(Config):
    
    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_queue = {}
    
    def get_vhost(self):
        return self.get("rabbitmq", "vhost")
    
    def get_username(self):
        return self.get("rabbitmq", "username")
    
    def get_password(self):
        return self.get("rabbitmq", "password")
    
    def get_hostname(self):
        return self.get("rabbitmq", "hostname")
    
    def get_port(self):
        return Integer.parseInt(
                self.get("rabbitmq", "port")
                )


class WebDavConfig(Config):
    """
    Configuration information for eXist WebDav
    """

    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}
    
    def get_bungeni_xml_folder(self):
        return self.get("webdav", "bungeni_xml_folder")

    def get_bungeni_atts_folder(self):
        return self.get("webdav", "bungeni_atts_folder")

    def get_fw_i18n_folder(self):
        return self.get("webdav", "framework_i18n_folder")

    def get_username(self):
        return self.get("webdav", "username")
    
    def get_password(self):
        return self.get("webdav", "password")

    def get_server(self):
        return self.get("webdav", "server")

    def get_port(self):
        return int(self.get("webdav", "port"))

    def get_http_server_port(self):
        return "http://"+self.get_server()+":"+str(self.get_port())


class PoTranslationsConfig(Config):
    """
    Configuration information for .po translation files
    """
    
    def __init__(self, config_file):
        Config.__init__(self, config_file)
        self.dict_pipes = {}

    def get_po_files_folder(self):
        return self.get("translations", "po_files_folder")

    def get_po_listing(self):
        return self.items("messages")

    def get_i18n_catalogues_folder(self):
        return self.get("translations", "i18n_catalogues_folder")

