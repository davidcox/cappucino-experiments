import dbus
import os

TSPIKE = 0
WAVE = 1
RAW = 2

class SomaManager:
    
    def __init__(self, soma_ip, data_dir):
        # start the recorder manager, if it is not already started
        dbus_addr = self.__get_dbus_session_bus_address()
        os.system("soma-recorder-manager --soma-ip %s --expdir %s --dbus %s" %
                            (soma_ip, data_dir, dbus_addr))
        
        # get the session bus
        self.bus = dbus.SessionBus()
        
        # set up the recorder dbus interface
        self.recorder = RecorderProxy(self.bus) 
        

    def __get_dbus_session_bus_address(self):
        return (os.popen("echo $DBUS_SESSION_ADDRESS")).read()


class RecorderProxy:
    
    available_experiments = property(_get_available_experiments)
    open_experiments = property(_get_open_experiments)
    
    def __init__(self, bus):
        self.bus = bus
        dbus_proxy = self.bus.get_object("soma.recording.Manager", "/manager")
        self.dbus_interface = dbus.Interface(dbus_proxy, "soma.recording.Manager")
    
    def create_experiment(self, name):
        self.dbus_interface.CreateExperiment(name)

    def open_experiment(self, name):
        self.dbus_interface.OpenExperiment(name)

    def _get_available_experiments(self):
        available = []
        exp_dbus_ifaces = self.dbus_interface.ListAvailableExperiments()
        for exp_iface in exp_dbus_ifaces:
            exp_proxy = ExperimentProxy(self.bus, exp_iface)
            available.append(exp_proxy)
        
        return available

    def _get_open_experiments(self):
        experiments = []
        exp_dbus_ids = self.dbus_interface.ListOpenExperiments()
        for exp_ids in exp_dbus_ids:
            exp_proxy = ExperimentProxy(self.bus, exp_id)
            experiments.append(exp_proxy)

        return experiments



class ExperimentProxy:
    
    epochs = property(_get_epochs)
    
    def __init__(self, bus, unique_id):
        self.bus = bus
        dbus_proxy = bus.get_object(unique_id, "/soma/recording/experiment")
        self.dbus_interface = dbus.interface(dbus_proxy, "soma.recording.Experiment")
    
    def create_epoch(self, name):
        self.dbus_interface.CreateEpoch(name)
    
    def _get_epochs(self):
        epochs = []
        epoch_ids = self.dbus_interface.GetEpochs()
        for epoch_id in epoch_ids:
            epoch_proxy = EpochProxy(self.bus, epoch_id)
            epochs.append(epoch_proxy)
        
        return epochs
        
class EpochProxy:
    
    is_recording = property(_get_is_recording)
    
    def __init__(self, bus, exp_id, epoch_path):
        self.bus = bus
        dbus_proxy = bus.get_object(exp_id, epoch_path)
        self.dbus_interface = dbus.Interface(dbus_proxy, "soma.recording.Epoch")
    
    def start_recording(self):
        self.dbus_interface.StartRecording()
        
    def stop_recording(self):    
        self.dbus_interface.StopRecording()
    
    def enable_tspike_src(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, TSPIKE)

    def disable_tspike_src(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, TSPIKE)

    def enable_wave_src(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, WAVE)

    def disable_wave_src(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, WAVE)

    def enable_raw_src(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, RAW)

    def disable_raw_src(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, RAW)
    
    def enable_all_srcs(self, n_channels):
        for i in range(0, n_channels):
            self.enable_tspike_src(i)
            self.enable_wave_src(i)
            self.enable_raw_src(i)
    
    
    def _get_is_recording(self):
        return self.dbus_interface.GetRecordingState()
        
