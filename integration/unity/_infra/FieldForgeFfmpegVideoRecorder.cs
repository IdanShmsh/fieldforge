using System;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;

namespace FieldForge
{
    [Serializable]
    public class FfmpegVideoRecorder : IVideoRecorder
    {
        private System.Diagnostics.Process _ffmpeg;
        private Stream _stdin;

        public FfmpegVideoRecorder(string outputPath, int width, int height, int frameRate)
        {
            string ffmpegExecutable = FindFFmpegExecutable();
            if (string.IsNullOrEmpty(ffmpegExecutable))
                throw new Exception("FFmpeg executable not found. Please ensure ffmpeg is installed and accessible.");

            string directory = Path.GetDirectoryName(outputPath);
            if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);

            var startInfo = new System.Diagnostics.ProcessStartInfo
            {
                FileName = ffmpegExecutable,
                Arguments = BuildFfmpegArguments(outputPath, width, height, frameRate),
                UseShellExecute = false,
                RedirectStandardInput = true,
                RedirectStandardError = true, // IMPORTANT: capture errors!
                CreateNoWindow = true
            };
            _ffmpeg = new System.Diagnostics.Process { StartInfo = startInfo };
            _ffmpeg.Start();
            if (_ffmpeg.HasExited)
            {
                string errorOutput = _ffmpeg.StandardError.ReadToEnd();
                throw new Exception($"FFmpeg failed to start. Error output:\n{errorOutput}");
            }
            _stdin = _ffmpeg.StandardInput.BaseStream;
            _ffmpeg.ErrorDataReceived += (sender, e) =>
            {
                if (!string.IsNullOrEmpty(e.Data)) Debug.LogWarning($"[FFmpeg] {e.Data}");
            };
            _ffmpeg.BeginErrorReadLine();
        }

        private static string BuildFfmpegArguments(string outputPath, int width, int height, int frameRate)
        {
            string ext = Path.GetExtension(outputPath).ToLowerInvariant();
            string common = $"-y -f rawvideo -vcodec rawvideo -pixel_format bgra -video_size {width}x{height} -framerate {frameRate} -i - ";

            if (ext == ".mov") return common + "-c:v prores_ks -profile:v 4444 -pix_fmt bgra \"" + outputPath + "\"";
            if (ext == ".mkv") return common + "-c:v ffv1 -level 3 -pix_fmt bgra \"" + outputPath + "\"";
            if (ext == ".mp4") return common + "-c:v libx264 -crf 0 -preset ultrafast -pix_fmt yuv444p \"" + outputPath + "\"";
            if (ext == ".avi") return common + "-c:v ffv1 -level 3 -pix_fmt bgra \"" + outputPath + "\"";

            return common + "-c:v libx264 -crf 0 -preset ultrafast -pix_fmt yuv444p \"" + outputPath + "\"";
        }

        public void CommitFrame(AsyncGPUReadbackRequest request, int width, int height)
        {
            if (!request.done || request.hasError) return;
            if (_ffmpeg.HasExited)
            {
                Debug.LogError("FFmpeg has exited before frame could be written.");
                return;
            }
            var data = request.GetData<byte>();
            if (!data.IsCreated || data.Length != width * height * 4) return;
            byte[] managedBytes = data.ToArray();
            _stdin.Write(managedBytes, 0, managedBytes.Length);
        }

        public void Dispose()
        {
            _stdin?.Flush();
            _stdin?.Close();
            _ffmpeg?.WaitForExit();
            _ffmpeg?.Dispose();
        }

        private static string FindFFmpegExecutable()
        {
            string[] possiblePaths;
#if UNITY_EDITOR_OSX || UNITY_STANDALONE_OSX
            possiblePaths = new[]
            {
                "ffmpeg",
                "/opt/homebrew/bin/ffmpeg",
                "/usr/local/bin/ffmpeg"
            };
#elif UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN
            possiblePaths = new[]
            {
                "ffmpeg",
                System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "ffmpeg", "bin", "ffmpeg.exe"),
                System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "ffmpeg", "bin", "ffmpeg.exe"),
                "ffmpeg.exe"
            };
#elif UNITY_EDITOR_LINUX || UNITY_STANDALONE_LINUX
            possiblePaths = new[]
            {
                "ffmpeg",
                "/usr/bin/ffmpeg",
                "/usr/local/bin/ffmpeg"
            };
#else
            possiblePaths = new[] { "ffmpeg" };
#endif

            foreach (var path in possiblePaths)
            {
                try
                {
                    var process = new System.Diagnostics.Process
                    {
                        StartInfo = new System.Diagnostics.ProcessStartInfo
                        {
                            FileName = path,
                            Arguments = "-version",
                            RedirectStandardOutput = true,
                            UseShellExecute = false,
                            CreateNoWindow = true
                        }
                    };
                    process.Start();
                    process.WaitForExit();
                    if (process.ExitCode == 0)
                    {
                        Debug.Log($"FFmpeg found at: {path}");
                        return path;
                    }
                }
                catch
                {
                    // Ignore and continue
                }
            }

            Debug.LogWarning("FFmpeg executable not found on this machine.");
            return null;
        }
    }
}