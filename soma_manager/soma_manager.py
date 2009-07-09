import dbus
import os

TSPIKE = 0
WAVE = 1
RAW = 2

class SomaManager:
    
    def __init__(self, soma_ip, data_dir):
        # start the recorder manager, if it is not already started
        dbus_addr = self.__get_dbus_session_bus_address()
        #os.system("soma-recorder-manager --soma-ip %s --expdir %s --dbus %s &" %
        #                    (soma_ip, data_dir, dbus_addr))
        
        # get the session bus
        self.bus = dbus.SessionBus()
        
        # set up the recorder dbus interface
        self.recorder = RecorderProxy(self.bus) 
        

    def __get_dbus_session_bus_address(self):
        return (os.popen("echo $DBUS_SESSION_BUS_ADDRESS")).read()


class RecorderProxy:
        
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
        for exp_id in exp_dbus_ifaces:
            exp_proxy = ExperimentProxy(self, self.bus, exp_id)
            available.append(exp_proxy)
        
        return available

    def _get_active_experiments(self):
        experiments = []
        exp_dbus_ids = self.dbus_interface.ListOpenExperiments()
        for exp_id in exp_dbus_ids:
            exp_proxy = ExperimentProxy(self, self.bus, exp_id)
            experiments.append(exp_proxy)

        return experiments
    

    def _get_available_experiment_dictionary(self):
        return self._make_experiment_dict(self.available_experiments)

    def _get_active_experiment_dictionary(self):
        return self._make_experiment_dict(self.active_experiments)

    def _make_experiment_dict(self, experiments):
        exp_dict = {}
        for exp in experiments:
            exp_dict[exp.name] = exp
        return exp_dict


    available_experiments = property(_get_available_experiments)
    active_experiments = property(_get_active_experiments)
    available_experiment_dictionary = property(_get_available_experiment_dictionary)
    active_experiment_dictionary = property(_get_active_experiment_dictionary)

class ExperimentProxy:
    

    def __init__(self, parent, bus, unique_id):
        self.bus = bus
        self.parent = parent
        self.unique_id = unique_id
        dbus_proxy = bus.get_object(unique_id, "/soma/recording/experiment")
        self.dbus_interface = dbus.Interface(dbus_proxy, "soma.recording.Experiment")
    
    def close(self):
        self.dbus_interface.Close()

    def create_epoch(self, name):
        self.dbus_interface.CreateEpoch(name)
    
    def _get_epochs(self):
        epochs = []
        epoch_ids = self.dbus_interface.GetEpochs()
        for epoch_id in epoch_ids:
            epoch_proxy = EpochProxy(self, self.bus, epoch_id)
            epochs.append(epoch_proxy)
        
        return epochs

    def _get_name(self):
        namestring = self.dbus_interface.GetName() + ""
        return namestring.split("/")[-1]

    epochs = property(_get_epochs)
    name = property(_get_name)    


class EpochProxy:
    
    
    def __init__(self, parent,bus, epoch_path):
        self.bus = bus
        self.parent = parent
        dbus_proxy = bus.get_object(parent.unique_id, epoch_path)
        self.dbus_interface = dbus.Interface(dbus_proxy, "soma.recording.Epoch")
    
    def start_recording(self):
        self.dbus_interface.StartRecording()
        
    def stop_recording(self):    
        self.dbus_interface.StopRecording()
    
    def enable_tspike_sink(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, TSPIKE)

    def disable_tspike_sink(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, TSPIKE)

    def enable_wave_sink(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, WAVE)

    def disable_wave_sink(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, WAVE)

    def enable_raw_sink(self, src_id):
        self.dbus_interface.EnableDataSink(src_id, RAW)

    def disable_raw_sink(self, src_id):
        self.dbus_interface.DisableDataSink(src_id, RAW)
    
    def enable_all_sinks(self, n_channels):
        for i in range(0, n_channels):
            self.enable_tspike_sink(i)
            self.enable_wave_sink(i)
            self.enable_raw_sink(i)
    
    def _get_name(self):
        return self.dbus_interface.GetName() + ""

    def _get_is_recording(self):
        return self.dbus_interface.GetRecordingState() and True

    is_recording = property(_get_is_recording)   
    name = property(_get_name)

    def _get_sink_name(self, src_id):
        return self.dbus_interface.GetDataName(src_id)

    def _set_sink_name(self, src_id, name):
        self.dbus_interface.SetDataName(src_id, name)

# class DataSink:
# 
#     def __init__(self, epoch, src_id):
#         self.parent = epoch
#         self.src_id = src_id
# 
#     def _get_name(self):
#         self.parent._get_sink_name(self.src_id)
# 
#     def _set_name(self, name):
#         self.parent._set_sink_name(self.src_id, name)
# 
#     def enable_tspikes(self):
#         self.parent.enable_tspike_sink(self.src_id)
# 
#     def disable_tspikes(self):
#         self.parent_disable_tspike_sink(self.src_id)
# 
#     def enable_waves(self):
#         self.parent.enable_wave_sink(self.src_id)
# 
#     def disable_waves(self):
#         self.parent.disable_wave_sink(self.src_id)
# 
#     def enable_raw(self):
#         self.parent.enable_raw_sink(self.src_id)
# 
#     def disable_raw(self):
#         self.parent.disable_raw_sink(self.src_id)
# 
#     def _tspikes_enabled(self):
#         # TODO: would be better with better hooks
#     
# 
#     name = property(_get_name, _set_name)
#         

if __name__ == '__main__':

    import time
    manager = SomaManager("10.0.0.2", "~/data")
    recorder = manager.recorder
    
    exps = recorder.active_experiments
    exp = exps[0]
    epochs = exp.epochs

    epoch = epochs[0]
    epoch.enable_all_srcs(32)
    epoch.start_recording()
    print("Recording...")
    time.sleep(10)
    time.stop_recording()
    exp.close()

