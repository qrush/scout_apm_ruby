# Serialize & deserialize data from the instrumented app up to the APM server
module ScoutApm
  module Serializers
    class PayloadSerializer
      def self.serialize(metadata, metrics, slow_transactions, jobs, slow_jobs, histograms)
        if ScoutApm::Agent.instance.config.value("report_format") == 'json'
          ScoutApm::Serializers::PayloadSerializerToJson.serialize(metadata, metrics, slow_transactions, jobs, slow_jobs, histograms)
        else
          metadata = metadata.dup
          metadata.default = nil

          metrics = metrics.dup
          metrics.default = nil
          Marshal.dump(:metadata          => metadata,
                       :metrics           => metrics,
                       :slow_transactions => slow_transactions,
                       :jobs              => jobs,
                       :slow_jobs         => slow_jobs,

                       # as_json returns a ruby object. Since it's not a simple
                       # array, use this to maintain compatibility with json
                       # payloads. At this point, the marshal code branch is
                       # very rarely used anyway.
                       :histograms        => HistogramsSerializerToJson.new(histograms).as_json)
        end
      end

      def self.deserialize(data)
        Marshal.load(data)
      end
    end
  end
end
